#!/usr/bin/env python3
"""
BMS Reader para DP04S007L4S200A
Lee datos del BMS vía Bluetooth BLE usando protocolo JBD
"""
import asyncio
import logging
import sys
import json
import os
from bleak import BleakClient, BleakScanner, BLEDevice, BleakError
from dp04s_protocol import DP04SProtocol, format_battery_status

# Configuración
BATTERY_MAC = os.environ.get('BMS_MAC_ADDRESS', 'A5:C2:37:40:48:56')
SCAN_TIMEOUT = 10.0
CONNECT_TIMEOUT = 10.0
JSON_OUTPUT = os.environ.get('BMS_JSON_OUTPUT', 'false').lower() == 'true'

# UUID características BLE
RX_CHAR_UUID = "0000ff01-0000-1000-8000-00805f9b34fb"  # Notify
TX_CHAR_UUID = "0000ff02-0000-1000-8000-00805f9b34fb"  # Write

# Logging - Si es JSON output, solo mostrar errores en stderr
log_level = logging.ERROR if JSON_OUTPUT else logging.INFO
logging.basicConfig(
    level=log_level,
    format='%(asctime)s - %(levelname)s - %(message)s',
    stream=sys.stderr  # Enviar logs a stderr para no contaminar stdout
)
logger = logging.getLogger(__name__)


class BMSReader:
    """Lector BMS BLE"""
    
    def __init__(self, mac_address: str):
        self.mac_address = mac_address
        self.client: BleakClient | None = None
        self.basic_info = None
        self.cell_info = None
        self.data_received = asyncio.Event()
        self.pending_data = bytearray()  # Buffer para mensajes fragmentados
        
    def notification_handler(self, sender: int, data: bytearray):
        """Manejador de notificaciones BLE"""
        if len(data) > 0:
            # Los mensajes pueden venir fragmentados, acumular
            self.pending_data.extend(data)
            
            # Intentar parsear si tenemos suficientes bytes
            if len(self.pending_data) >= 7:
                # Verificar si tenemos mensaje completo (end byte 0x77)
                if self.pending_data[-1] == 0x77:
                    # Parsear mensaje completo
                    parsed = DP04SProtocol.parse(bytes(self.pending_data))
                    
                    if parsed and parsed['type'] == 'BASIC_INFO':
                        self.basic_info = parsed
                        logger.info(f"📦 Info básica: V={parsed['voltage']:.2f}V, I={parsed['current']:.2f}A, SOC={parsed['soc_pct']:.1f}%")
                        self.data_received.set()
                    elif parsed and parsed['type'] == 'CELL_VOLTAGES':
                        self.cell_info = parsed
                        cells_str = ', '.join([f"{v:.3f}V" for v in parsed['cell_voltages']])
                        logger.info(f"🔋 Voltajes celdas: [{cells_str}]")
                        self.data_received.set()
                    
                    # Limpiar buffer
                    self.pending_data = bytearray()
    
    async def scan_for_device(self) -> BLEDevice | None:
        """Escanear dispositivo BLE"""
        logger.info(f"🔍 Escaneando {self.mac_address}...")
        
        device = await BleakScanner.find_device_by_address(
            self.mac_address,
            timeout=SCAN_TIMEOUT
        )
        
        if device:
            logger.info(f"✓ Encontrado: {device.name}")
        else:
            logger.error(f"✗ No encontrado")
        
        return device
    
    async def read_battery(self) -> bool:
        """Leer datos de la batería"""
        device = await self.scan_for_device()
        if not device:
            return False
        
        try:
            logger.info(f"🔌 Conectando...")
            
            async with BleakClient(device, timeout=CONNECT_TIMEOUT) as client:
                self.client = client
                
                if not client.is_connected:
                    logger.error("✗ Fallo en conexión")
                    return False
                
                logger.info("✓ Conectado")
                
                # Suscribirse a notificaciones
                logger.info(f"📻 Suscribiéndose a notificaciones...")
                await client.start_notify(RX_CHAR_UUID, self.notification_handler)
                
                # Enviar comando para información básica
                logger.info(f"📤 Solicitando información básica...")
                await client.write_gatt_char(TX_CHAR_UUID, DP04SProtocol.CMD_BASIC_INFO, response=False)
                
                # Esperar respuesta
                try:
                    await asyncio.wait_for(self.data_received.wait(), timeout=5.0)
                    self.data_received.clear()
                except asyncio.TimeoutError:
                    logger.warning("⏱️  Timeout esperando información básica")
                
                # Enviar comando para voltajes de celdas
                logger.info(f"📤 Solicitando voltajes de celdas...")
                await client.write_gatt_char(TX_CHAR_UUID, DP04SProtocol.CMD_CELL_VOLTAGES, response=False)
                
                # Esperar respuesta
                try:
                    await asyncio.wait_for(self.data_received.wait(), timeout=5.0)
                except asyncio.TimeoutError:
                    logger.warning("⏱️  Timeout esperando voltajes de celdas")
                
                # Desuscribirse
                try:
                    await client.stop_notify(RX_CHAR_UUID)
                except Exception as e:
                    logger.debug(f"Error al desuscribirse (ignorado): {e}")
                
                # Mostrar resultados solo si NO es JSON output
                if self.basic_info or self.cell_info:
                    if not JSON_OUTPUT:
                        print()
                        print(format_battery_status(self.basic_info, self.cell_info))
                    logger.info("✓ Lectura completada exitosamente")
                    return True
                else:
                    logger.warning("⚠️  No se recibieron datos")
                    return False
        
        except BleakError as e:
            logger.error(f"❌ Error BLE: {e}")
            # No retornar False aquí, continuar para imprimir datos si los hay
        except asyncio.TimeoutError:
            logger.error("❌ Timeout en operación BLE")
            # No retornar False aquí, continuar para imprimir datos si los hay
        except Exception as e:
            logger.error(f"❌ Error inesperado: {e}")
            # No retornar False aquí, continuar para imprimir datos si los hay
        finally:
            # Asegurar que el cliente se desconecte limpiamente
            if hasattr(self, 'client') and self.client and self.client.is_connected:
                try:
                    await self.client.disconnect()
                except Exception:
                    pass  # Ignorar errores al desconectar
        
        # Retornar True si tenemos al menos algo de datos
        return bool(self.basic_info or self.cell_info)


async def main():
    """Función principal"""
    # Parsear argumentos de línea de comandos
    if len(sys.argv) > 1:
        global BATTERY_MAC
        BATTERY_MAC = sys.argv[1]
    
    # Solo imprimir header si NO es JSON mode
    if not JSON_OUTPUT:
        print("=" * 70)
        print("  🔋 BMS Reader - DP04S007L4S200A")
        print("=" * 70)
        print()
    
    reader = BMSReader(BATTERY_MAC)
    success = await reader.read_battery()
    
    # Si JSON_OUTPUT está habilitado, imprimir SOLO JSON a stdout
    if JSON_OUTPUT:
        if reader.basic_info or reader.cell_info:
            import datetime
            
            output = {
                'device_address': BATTERY_MAC,
                'timestamp': datetime.datetime.now().isoformat(),
            }
            
            if reader.basic_info:
                output['basic_info'] = {
                    'voltage': reader.basic_info['voltage'],
                    'current': reader.basic_info['current'],
                    'soc_ah': reader.basic_info['soc_ah'],
                    'max_ah': reader.basic_info['max_ah'],
                    'soc_pct': reader.basic_info['soc_pct'],
                    'watts': reader.basic_info['watts'],
                    'temperature': reader.basic_info['temperature'],
                    'charge_enabled': reader.basic_info['charge_enabled'],
                    'discharge_enabled': reader.basic_info['discharge_enabled'],
                }
            
            if reader.cell_info:
                output['cell_info'] = {
                    'n_cells': reader.cell_info['n_cells'],
                    'cell_voltages': reader.cell_info['cell_voltages'],
                    'total_voltage': reader.cell_info['total_voltage'],
                    'max_cell_voltage': reader.cell_info['max_cell_voltage'],
                    'min_cell_voltage': reader.cell_info['min_cell_voltage'],
                    'cell_voltage_delta': reader.cell_info['cell_voltage_delta'],
                }
            
            # Imprimir SOLO JSON, nada más a stdout
            print(json.dumps(output, indent=2))
            return 0
        else:
            # Sin datos, retornar error
            return 1
    else:
        # Modo normal (no JSON)
        if not success:
            print("\n❌ No se pudieron leer datos del BMS")
            return 1
        return 0


if __name__ == "__main__":
    exit(asyncio.run(main()))
