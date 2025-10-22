"""
Protocolo DP04S007L4S200A / Eco-Worthy / JBD BMS
Basado en JDB RS485-RS232-UART-Bluetooth-Communication Protocol
"""
import struct
from typing import Dict, Optional


class DP04SProtocol:
    """Parser del protocolo JBD BMS usado en DP04S007L4S200A"""
    
    # Comandos
    CMD_BASIC_INFO = bytes([0xDD, 0xA5, 0x03, 0x00, 0xFF, 0xFD, 0x77])
    CMD_CELL_VOLTAGES = bytes([0xDD, 0xA5, 0x04, 0x00, 0xFF, 0xFC, 0x77])
    
    @staticmethod
    def parse_basic_info(data: bytes) -> Optional[Dict]:
        """
        Parse respuesta 0xDD 0x03 (información básica)
        
        Estructura según protocolo JBD:
        - Bytes 0-1: Header (0xDD 0x03)
        - Bytes 2-3: Length (big-endian)
        - Bytes 4-5: Voltage (big-endian, ÷100 = V)
        - Bytes 6-7: Current (big-endian signed, ÷100 = A)
        - Bytes 8-9: SOC Ah (big-endian, ÷100 = Ah)
        - Bytes 10-11: Max Ah (big-endian, ÷100 = Ah)
        - Bytes 24: Switches (charge/discharge mosfets)
        - Bytes 27-28: Temperature (big-endian, (value-2731)×0.1 = °C)
        - Byte -1: End byte (0x77)
        """
        if len(data) < 7:
            return None
            
        if data[0] != 0xDD or data[1] != 0x03:
            return None
        
        # Verificar end byte
        if data[-1] != 0x77:
            return None
        
        # Extraer longitud esperada
        length = struct.unpack('>H', data[2:4])[0]
        if len(data) != (length + 7):
            return None
        
        # Parsear campos
        voltage_raw = struct.unpack('>H', data[4:6])[0]
        voltage = voltage_raw / 100.0
        
        current_raw = struct.unpack('>h', data[6:8])[0]  # signed
        current = current_raw / 100.0
        
        soc_ah_raw = struct.unpack('>H', data[8:10])[0]
        soc_ah = soc_ah_raw / 100.0
        
        max_ah_raw = struct.unpack('>H', data[10:12])[0]
        max_ah = max_ah_raw / 100.0
        
        # SOC porcentaje
        if max_ah == 0:
            soc_pct = 0.0
        else:
            soc_pct = 100.0 * (soc_ah / max_ah)
        
        # Potencia
        watts = voltage * current
        
        # Temperatura (si hay suficientes bytes)
        temperature = None
        if len(data) >= 29:
            temp_raw = struct.unpack('>H', data[27:29])[0]
            temperature = (temp_raw - 2731) * 0.1
        
        # Switches (charge/discharge)
        switches = None
        charge_enabled = None
        discharge_enabled = None
        if len(data) >= 25:
            switches = data[24]
            charge_enabled = (switches & 0x01) == 0x01
            discharge_enabled = (switches & 0x02) == 0x02
        
        return {
            'type': 'BASIC_INFO',
            'voltage': voltage,
            'voltage_raw': voltage_raw,
            'current': current,
            'current_raw': current_raw,
            'soc_ah': soc_ah,
            'max_ah': max_ah,
            'soc_pct': soc_pct,
            'watts': watts,
            'temperature': temperature,
            'charge_enabled': charge_enabled,
            'discharge_enabled': discharge_enabled,
            'switches': switches,
            'raw_hex': data.hex(),
        }
    
    @staticmethod
    def parse_cell_voltages(data: bytes) -> Optional[Dict]:
        """
        Parse respuesta 0xDD 0x04 (voltajes de celdas)
        
        Estructura:
        - Bytes 0-1: Header (0xDD 0x04)
        - Bytes 2-3: Length (big-endian)
        - Byte 3: Número de celdas × 2
        - Bytes 4+: Voltajes de celdas (2 bytes cada una, big-endian, mV)
        - Byte -1: End byte (0x77)
        """
        if len(data) < 7:
            return None
            
        if data[0] != 0xDD or data[1] != 0x04:
            return None
        
        # Verificar end byte
        if data[-1] != 0x77:
            return None
        
        # Extraer longitud
        length = struct.unpack('>H', data[2:4])[0]
        if len(data) != (length + 7):
            return None
        
        # Número de celdas
        n_cells = int(data[3] / 2)
        
        # Parsear voltajes de celdas
        cell_voltages = []
        offset = 4
        for i in range(n_cells):
            if offset + 2 <= len(data) - 1:
                cell_mv = struct.unpack('>H', data[offset:offset+2])[0]
                cell_voltages.append(cell_mv / 1000.0)
                offset += 2
        
        # Estadísticas
        total_voltage = sum(cell_voltages)
        max_cell = max(cell_voltages) if cell_voltages else 0
        min_cell = min(cell_voltages) if cell_voltages else 0
        delta = max_cell - min_cell
        
        return {
            'type': 'CELL_VOLTAGES',
            'n_cells': n_cells,
            'cell_voltages': cell_voltages,
            'total_voltage': total_voltage,
            'max_cell_voltage': max_cell,
            'min_cell_voltage': min_cell,
            'cell_voltage_delta': delta,
            'raw_hex': data.hex(),
        }
    
    @staticmethod
    def parse(data: bytes) -> Optional[Dict]:
        """Parse cualquier mensaje del BMS"""
        if len(data) < 2:
            return None
        
        # Identificar tipo de mensaje por header
        if data[0] == 0xDD and data[1] == 0x03:
            return DP04SProtocol.parse_basic_info(data)
        elif data[0] == 0xDD and data[1] == 0x04:
            return DP04SProtocol.parse_cell_voltages(data)
        else:
            return {
                'type': 'UNKNOWN',
                'raw_hex': data.hex(),
            }


def format_battery_status(basic_info: Dict, cell_info: Dict = None) -> str:
    """Formatear estado completo de la batería"""
    lines = []
    lines.append("=" * 70)
    lines.append("  🔋 ESTADO DE LA BATERÍA DP04S007L4S200A")
    lines.append("=" * 70)
    
    if basic_info:
        lines.append(f"\n📊 Datos Generales:")
        lines.append(f"   Voltaje Total:    {basic_info['voltage']:.2f} V")
        lines.append(f"   Corriente:        {basic_info['current']:>6.2f} A")
        lines.append(f"   Potencia:         {basic_info['watts']:>6.2f} W")
        lines.append(f"   SOC:              {basic_info['soc_pct']:.1f} % ({basic_info['soc_ah']:.2f} / {basic_info['max_ah']:.2f} Ah)")
        
        if basic_info['temperature'] is not None:
            lines.append(f"   Temperatura:      {basic_info['temperature']:.1f} °C")
        
        if basic_info['charge_enabled'] is not None:
            charge_status = "✅" if basic_info['charge_enabled'] else "❌"
            discharge_status = "✅" if basic_info['discharge_enabled'] else "❌"
            lines.append(f"   Carga habilitada: {charge_status}")
            lines.append(f"   Descarga habilitada: {discharge_status}")
    
    if cell_info:
        lines.append(f"\n🔋 Voltajes de Celdas ({cell_info['n_cells']} celdas):")
        for i, v in enumerate(cell_info['cell_voltages'], 1):
            lines.append(f"   Celda {i}:          {v:.3f} V")
        lines.append(f"   Total celdas:     {cell_info['total_voltage']:.3f} V")
        lines.append(f"   Delta max-min:    {cell_info['cell_voltage_delta']:.3f} V")
        
        # Advertencia si hay desbalanceo
        if cell_info['cell_voltage_delta'] > 0.1:
            lines.append(f"\n   ⚠️  ADVERTENCIA: Desbalanceo de celdas > 0.1V")
            lines.append(f"       Se recomienda balanceo de celdas")
    
    lines.append("=" * 70)
    return "\n".join(lines)
