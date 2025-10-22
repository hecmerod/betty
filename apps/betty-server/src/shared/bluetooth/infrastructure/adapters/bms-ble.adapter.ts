import { Injectable, Logger } from '@nestjs/common';
import { exec } from 'child_process';
import { promisify } from 'util';
import { join } from 'path';

const execAsync = promisify(exec);

export interface BmsBasicInfo {
  voltage: number;
  current: number;
  soc_ah: number;
  max_ah: number;
  soc_pct: number;
  watts: number;
  temperature: number | null;
  charge_enabled: boolean | null;
  discharge_enabled: boolean | null;
}

export interface BmsCellInfo {
  n_cells: number;
  cell_voltages: number[];
  total_voltage: number;
  max_cell_voltage: number;
  min_cell_voltage: number;
  cell_voltage_delta: number;
}

export interface BmsData {
  device_address: string;
  timestamp: Date;
  basic_info: BmsBasicInfo;
  cell_info: BmsCellInfo;
}

/**
 * Adapter para comunicación BLE con BMS DP04S007L4S200A
 * Ejecuta script de Python que usa bleak para leer datos del BMS
 */
@Injectable()
export class BmsBleAdapter {
  private readonly logger = new Logger(BmsBleAdapter.name);
  private readonly pythonScriptPath: string;
  private readonly pythonVenvPath: string;

  constructor() {
    // Ruta al script de Python en betty-camera
    const cameraPath = join(process.cwd(), '..', 'betty-camera');
    this.pythonScriptPath = join(cameraPath, 'src', 'read_bms.py');
    this.pythonVenvPath = join(cameraPath, 'venv', 'bin', 'python');
  }

  /**
   * Lee datos del BMS por Bluetooth BLE
   * @param deviceAddress MAC address del BMS (ej: A5:C2:37:40:48:56)
   * @returns Datos completos del BMS
   */
  async readBmsData(deviceAddress: string): Promise<BmsData> {
    this.logger.log(`Leyendo datos del BMS ${deviceAddress}...`);

    try {
      // Ejecutar script de Python con sudo y variable de entorno
      // Usar sudo -E para preservar variables de entorno
      const command = `sudo -E BMS_JSON_OUTPUT=true ${this.pythonVenvPath} ${this.pythonScriptPath} ${deviceAddress}`;

      const { stdout, stderr } = await execAsync(command, {
        timeout: 30000, // 30 segundos timeout
        env: {
          ...process.env,
          BMS_JSON_OUTPUT: 'true',
        },
      });

      // Intentar parsear JSON del stdout (incluso si hay errores en stderr)
      let jsonData;
      try {
        jsonData = JSON.parse(stdout.trim());
      } catch (parseError) {
        // Si hay error parseando, loguear stderr para debug
        if (stderr) {
          this.logger.debug(`stderr del script: ${stderr}`);
        }
        throw new Error(`Failed to parse JSON output: ${parseError.message}`);
      }

      // Si llegamos aquí, el JSON es válido. Warnings en stderr se ignoran
      if (stderr && stderr.includes('ERROR')) {
        this.logger.warn(
          `Script reportó errores pero retornó datos válidos: ${stderr.substring(
            0,
            200
          )}...`
        );
      }

      const data: BmsData = {
        device_address: jsonData.device_address,
        timestamp: new Date(jsonData.timestamp),
        basic_info: jsonData.basic_info,
        cell_info: jsonData.cell_info,
      };

      this.logger.log(`Datos del BMS ${deviceAddress} leídos correctamente`);

      return data;
    } catch (error) {
      this.logger.error(`Error leyendo BMS ${deviceAddress}: ${error.message}`);
      throw new Error(`Failed to read BMS data: ${error.message}`);
    }
  }

  async readMultipleBms(deviceAddresses: string[]): Promise<BmsData[]> {
    const results: BmsData[] = [];
    for (const address of deviceAddresses) {
      try {
        results.push(await this.readBmsData(address));
      } catch (error) {
        this.logger.error(`Error leyendo BMS ${address}: ${error.message}`);
      }
    }
    return results;
  }

  /**
   * Verifica si el adapter BLE está disponible
   */
  async isAdapterAvailable(): Promise<boolean> {
    try {
      const { stdout } = await execAsync('hciconfig hci1');
      return stdout.includes('UP RUNNING');
    } catch {
      this.logger.warn('Adapter BLE hci1 no disponible');
      return false;
    }
  }

  /**
   * Escanea dispositivos BLE cercanos
   */
  async scanBleDevices(durationSeconds = 10): Promise<string[]> {
    this.logger.log(`Escaneando dispositivos BLE por ${durationSeconds}s...`);

    try {
      const command = `sudo timeout ${durationSeconds} hcitool -i hci1 lescan`;
      const { stdout } = await execAsync(command);

      // Parsear output: "A5:C2:37:40:48:56 DP04S007L4S200A"
      const devices = stdout
        .split('\n')
        .filter((line) => line.includes('DP04S007L4S200A'))
        .map((line) => {
          const match = line.match(/([0-9A-F:]+)/i);
          return match ? match[1] : null;
        })
        .filter((addr): addr is string => addr !== null);

      this.logger.log(`Encontrados ${devices.length} dispositivos BMS`);

      return [...new Set(devices)]; // Eliminar duplicados
    } catch (error) {
      this.logger.error(`Error escaneando dispositivos BLE: ${error.message}`);
      return [];
    }
  }
}
