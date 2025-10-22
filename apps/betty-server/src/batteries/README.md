# 🔋 Módulo de Baterías BMS

Módulo para monitoreo de baterías LiFePO4 DP04S007L4S200A mediante Bluetooth BLE.

## 📋 Descripción

Este módulo permite leer y monitorizar en tiempo real el estado de las baterías BMS (Battery Management System) a través de Bluetooth Low Energy (BLE). Utiliza el protocolo JBD BMS para comunicarse con las baterías Eco-Worthy / DP04S007L4S200A.

## 🔌 Arquitectura

```
betty-server (NestJS)
  └── BatteriesModule
      ├── BatteriesController (API REST)
      ├── BatteriesService (Lógica de negocio)
      └── BmsBleAdapter (Comunicación BLE)
          └── Llama a → betty-camera/src/read_bms.py (Python + bleak)
```

## 📡 API Endpoints

### GET /batteries

Obtiene el estado completo de todas las baterías configuradas.

**Respuesta:**

```json
[
  {
    "device_address": "A5:C2:37:40:48:56",
    "timestamp": "2025-10-22T17:20:21.394Z",
    "basic_info": {
      "voltage": 13.28,
      "current": -1.3,
      "soc_ah": 253.84,
      "max_ah": 280.0,
      "soc_pct": 90.7,
      "watts": -17.26,
      "temperature": 24.9,
      "charge_enabled": true,
      "discharge_enabled": true
    },
    "cell_info": {
      "n_cells": 4,
      "cell_voltages": [3.321, 3.32, 3.321, 3.32],
      "total_voltage": 13.282,
      "max_cell_voltage": 3.321,
      "min_cell_voltage": 3.32,
      "cell_voltage_delta": 0.001
    }
  }
]
```

### GET /batteries/summary

Obtiene un resumen del estado de todas las baterías.

**Respuesta:**

```json
{
  "total_batteries": 2,
  "total_voltage": 26.56,
  "total_current": -2.6,
  "total_power": -34.52,
  "total_capacity_ah": 560.0,
  "total_soc_pct": 90.5,
  "batteries": [
    {
      "address": "A5:C2:37:40:48:56",
      "voltage": 13.28,
      "current": -1.3,
      "soc_pct": 90.7,
      "temperature": 24.9,
      "cell_delta": 0.001,
      "status": "healthy"
    }
  ]
}
```

### GET /batteries/scan

Escanea dispositivos BMS disponibles en el área.

**Respuesta:**

```json
{
  "found": 2,
  "devices": ["A5:C2:37:40:48:56", "A5:C2:37:2F:23:CE"]
}
```

### GET /batteries/:address

Obtiene el estado de una batería específica por su dirección MAC.

**Parámetros:**

- `address`: Dirección MAC de la batería (puede usar `-` o `:` como separador)

**Ejemplo:**

```
GET /batteries/A5-C2-37-40-48-56
GET /batteries/A5:C2:37:40:48:56
```

## 🔧 Configuración

### Direcciones de baterías

Las direcciones MAC de las baterías se configuran en `batteries.service.ts`:

```typescript
private readonly batteryAddresses = [
  'A5:C2:37:40:48:56', // Batería 1
  'A5:C2:37:2F:23:CE', // Batería 2
];
```

### Script de Python

El script de lectura se encuentra en:

```
apps/betty-camera/src/read_bms.py
```

Variables de entorno soportadas:

- `BMS_MAC_ADDRESS`: Dirección MAC del BMS
- `BMS_JSON_OUTPUT`: Si es `true`, retorna JSON en lugar de formato legible

## 📊 Estados de salud

El servicio determina automáticamente el estado de salud de cada batería:

| Estado               | Descripción                       |
| -------------------- | --------------------------------- |
| `healthy`            | Batería funcionando correctamente |
| `warning_unbalanced` | Desbalanceo de celdas > 0.1V      |
| `warning_hot`        | Temperatura > 45°C                |
| `warning_cold`       | Temperatura < 0°C                 |
| `warning_low_soc`    | SOC < 20%                         |
| `error_disabled`     | Carga o descarga deshabilitada    |

## 🔌 Protocolo JBD BMS

El módulo utiliza el protocolo JBD BMS (Jiabaida):

**Comandos:**

- `0xDD 0xA5 0x03 0x00 0xFF 0xFD 0x77` - Solicitar información básica
- `0xDD 0xA5 0x04 0x00 0xFF 0xFC 0x77` - Solicitar voltajes de celdas

**Respuestas:**

- `0xDD 0x03 ...` - Información básica (voltaje, corriente, SOC, temperatura)
- `0xDD 0x04 ...` - Voltajes individuales de celdas

## 🛠️ Dependencias

### Python (betty-camera)

```bash
cd apps/betty-camera
python3 -m venv venv
source venv/bin/activate
pip install bleak
```

### NestJS (betty-server)

El módulo se integra automáticamente al importar `BatteriesModule`.

## 🚀 Uso

### Desde el servidor NestJS

```typescript
@Injectable()
export class MyService {
  constructor(private readonly batteriesService: BatteriesService) {}

  async checkBatteries() {
    const summary = await this.batteriesService.getBatteriesSummary();
    console.log(`SOC total: ${summary.total_soc_pct}%`);
  }
}
```

### Desde la API REST

```bash
# Obtener estado de todas las baterías
curl http://localhost:3000/batteries

# Obtener resumen
curl http://localhost:3000/batteries/summary

# Escanear baterías disponibles
curl http://localhost:3000/batteries/scan

# Obtener batería específica
curl http://localhost:3000/batteries/A5-C2-37-40-48-56
```

## ⚠️ Consideraciones

1. **Permisos**: El script de Python se ejecuta con `sudo` para acceder al Bluetooth
2. **Timeout**: Cada lectura tiene un timeout de 30 segundos
3. **Adapter**: Utiliza el adapter `hci1` (Bluetooth integrado de Raspberry Pi)
4. **Frecuencia**: No se recomienda leer más de una vez cada 10 segundos por batería

## 📝 Logs

Los logs del módulo incluyen:

```
[BatteriesService] Obteniendo estado de todas las baterías...
[BmsBleAdapter] Leyendo datos del BMS A5:C2:37:40:48:56...
[BmsBleAdapter] Datos del BMS A5:C2:37:40:48:56 leídos correctamente
[BatteriesService] Estado obtenido de 2 baterías
```

## 🐛 Troubleshooting

### Error: "Failed to connect to battery"

- Verificar que el BMS esté encendido y dentro del alcance
- Comprobar que el adapter hci1 esté activo: `hciconfig hci1`
- Intentar escanear manualmente: `sudo hcitool -i hci1 lescan`

### Error: "Adapter BLE hci1 no disponible"

- Verificar estado del Bluetooth: `systemctl status bluetooth`
- Desbloquear RF: `sudo rfkill unblock bluetooth`
- Reiniciar adapter: `sudo hciconfig hci1 down && sudo hciconfig hci1 up`

### Error: "No module named 'bleak'"

- Instalar bleak en el venv: `cd apps/betty-camera && source venv/bin/activate && pip install bleak`

## 📚 Referencias

- [Protocolo JBD BMS](https://jiabaida-bms.com/pages/download-files)
- [Biblioteca bleak (Python BLE)](https://github.com/hbldh/bleak)
- [DP04S007L4S200A Datasheet](https://www.eco-worthy.com/)
