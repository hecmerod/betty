import { Injectable, Logger, Inject } from '@nestjs/common';
import {
  BmsBleAdapter,
  BmsData,
} from '../../shared/bluetooth/infrastructure/adapters/bms-ble.adapter';
import { BMS_BLE_ADAPTER } from '../../shared/bluetooth/infrastructure/ioc/bluetooth.symbols';

@Injectable()
export class BatteriesService {
  private readonly logger = new Logger(BatteriesService.name);

  // Direcciones MAC de las baterías configuradas
  private readonly batteryAddresses = [
    'A5:C2:37:40:48:56', // Batería 1
    'A5:C2:37:2F:23:CE', // Batería 2
  ];

  constructor(
    @Inject(BMS_BLE_ADAPTER)
    private readonly bmsAdapter: BmsBleAdapter
  ) {}

  /**
   * Obtiene el estado actual de todas las baterías
   */
  async getAllBatteriesStatus(): Promise<BmsData[]> {
    this.logger.log('Obteniendo estado de todas las baterías...');

    const batteries = await this.bmsAdapter.readMultipleBms(
      this.batteryAddresses
    );

    this.logger.log(`Estado obtenido de ${batteries.length} baterías`);

    return batteries;
  }

  /**
   * Obtiene el estado de una batería específica
   */
  async getBatteryStatus(deviceAddress: string): Promise<BmsData> {
    this.logger.log(`Obteniendo estado de batería ${deviceAddress}...`);

    const battery = await this.bmsAdapter.readBmsData(deviceAddress);

    this.logger.log(`Estado de batería ${deviceAddress} obtenido`);

    return battery;
  }

  /**
   * Escanea dispositivos BMS disponibles
   */
  async scanBatteries(): Promise<string[]> {
    this.logger.log('Escaneando baterías BMS...');

    const devices = await this.bmsAdapter.scanBleDevices(10);

    this.logger.log(`Encontradas ${devices.length} baterías`);

    return devices;
  }

  /**
   * Obtiene resumen del estado de las baterías
   */
  async getBatteriesSummary() {
    const batteries = await this.getAllBatteriesStatus();

    const summary = {
      total_batteries: batteries.length,
      total_voltage: 0,
      total_current: 0,
      total_power: 0,
      total_capacity_ah: 0,
      total_soc_pct: 0,
      batteries: batteries.map((battery) => ({
        address: battery.device_address,
        voltage: battery.basic_info.voltage,
        current: battery.basic_info.current,
        soc_pct: battery.basic_info.soc_pct,
        temperature: battery.basic_info.temperature,
        cell_delta: battery.cell_info.cell_voltage_delta,
        status: this.getBatteryHealthStatus(battery),
      })),
    };

    // Calcular totales
    for (const battery of batteries) {
      summary.total_voltage += battery.basic_info.voltage;
      summary.total_current += battery.basic_info.current;
      summary.total_power += battery.basic_info.watts;
      summary.total_capacity_ah += battery.basic_info.max_ah;
      summary.total_soc_pct += battery.basic_info.soc_pct;
    }

    // Promediar SOC
    if (batteries.length > 0) {
      summary.total_soc_pct /= batteries.length;
    }

    return summary;
  }

  /**
   * Determina el estado de salud de una batería
   */
  private getBatteryHealthStatus(battery: BmsData): string {
    const { basic_info, cell_info } = battery;

    // Verificar desbalanceo de celdas
    if (cell_info.cell_voltage_delta > 0.1) {
      return 'warning_unbalanced';
    }

    // Verificar temperatura alta
    if (basic_info.temperature && basic_info.temperature > 45) {
      return 'warning_hot';
    }

    // Verificar temperatura baja
    if (basic_info.temperature && basic_info.temperature < 0) {
      return 'warning_cold';
    }

    // Verificar SOC bajo
    if (basic_info.soc_pct < 20) {
      return 'warning_low_soc';
    }

    // Verificar carga/descarga deshabilitada
    if (!basic_info.charge_enabled || !basic_info.discharge_enabled) {
      return 'error_disabled';
    }

    return 'healthy';
  }
}
