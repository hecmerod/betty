import { Injectable, Logger } from '@nestjs/common';
import { exec } from 'child_process';
import { promisify } from 'util';
import { VehicleData } from '../../domain/entities/vehicle-data.entity';

const execAsync = promisify(exec);

interface OBDCommand {
  pid: string;
  name: string;
  parse: (value: string) => number | null;
}

@Injectable()
export class ObdiiBluetoothAdapter {
  private readonly logger = new Logger(ObdiiBluetoothAdapter.name);
  private readonly obdCommands: OBDCommand[] = [
    {
      pid: '010C',
      name: 'RPM',
      parse: (v) => this.parseRPM(v),
    },
    {
      pid: '010D',
      name: 'Speed',
      parse: (v) => this.parseSpeed(v),
    },
    {
      pid: '0104',
      name: 'Engine Load',
      parse: (v) => this.parsePercentage(v),
    },
    {
      pid: '0105',
      name: 'Coolant Temp',
      parse: (v) => this.parseTemp(v),
    },
    {
      pid: '012F',
      name: 'Fuel Level',
      parse: (v) => this.parsePercentage(v),
    },
    {
      pid: '0111',
      name: 'Throttle Position',
      parse: (v) => this.parsePercentage(v),
    },
    {
      pid: '010F',
      name: 'Intake Temp',
      parse: (v) => this.parseTemp(v),
    },
    {
      pid: '0110',
      name: 'MAF',
      parse: (v) => this.parseMAF(v),
    },
    {
      pid: '0142',
      name: 'Voltage',
      parse: (v) => this.parseVoltage(v),
    },
  ];

  async scanVehicle(deviceAddress: string): Promise<VehicleData> {
    this.logger.log(`🚗 Escaneando vehículo vía OBDII: ${deviceAddress}`);

    const data: Record<string, number | null> = {};

    try {
      // Conectar al dispositivo OBDII via Bluetooth
      await this.connectDevice(deviceAddress);

      // Inicializar OBDII
      await this.sendCommand(deviceAddress, 'ATZ'); // Reset
      await this.delay(1000);
      await this.sendCommand(deviceAddress, 'ATE0'); // Echo off
      await this.sendCommand(deviceAddress, 'ATL0'); // Linefeeds off
      await this.sendCommand(deviceAddress, 'ATSP0'); // Auto protocol

      // Leer todos los PIDs
      for (const cmd of this.obdCommands) {
        try {
          const response = await this.sendCommand(deviceAddress, cmd.pid);
          data[cmd.name.toLowerCase().replace(/ /g, '_')] = cmd.parse(
            response
          );
          this.logger.debug(`${cmd.name}: ${data[cmd.name]}`);
        } catch (error) {
          this.logger.warn(`Error leyendo ${cmd.name}: ${error.message}`);
          data[cmd.name.toLowerCase().replace(/ /g, '_')] = null;
        }
      }

      await this.disconnectDevice(deviceAddress);

      return new VehicleData(
        data['rpm'],
        data['speed'],
        data['engine_load'],
        data['coolant_temp'],
        data['fuel_level'],
        data['throttle_position'],
        data['intake_temp'],
        data['maf'],
        data['voltage'],
        new Date()
      );
    } catch (error) {
      this.logger.error(`❌ Error escaneando vehículo: ${error.message}`);
      throw error;
    }
  }

  async findObdDevice(): Promise<string | null> {
    try {
      this.logger.log('🔍 Buscando dispositivo OBDII...');

      // Escanear dispositivos Bluetooth
      const { stdout } = await execAsync('bluetoothctl devices');
      const devices = stdout.split('\n').filter(Boolean);

      // Buscar dispositivos OBDII comunes (OBDII, ELM327, etc)
      const obdDevice = devices.find(
        (device) =>
          device.toLowerCase().includes('obd') ||
          device.toLowerCase().includes('elm327') ||
          device.toLowerCase().includes('vlink')
      );

      if (obdDevice) {
        const address = obdDevice.split(' ')[1];
        this.logger.log(`✅ Dispositivo OBDII encontrado: ${address}`);
        return address;
      }

      this.logger.warn('⚠️ No se encontró dispositivo OBDII');
      return null;
    } catch (error) {
      this.logger.error(`Error buscando dispositivo: ${error.message}`);
      return null;
    }
  }

  private async connectDevice(address: string): Promise<void> {
    try {
      await execAsync(`bluetoothctl connect ${address}`);
      await this.delay(2000);
      this.logger.debug(`Conectado a ${address}`);
    } catch (error) {
      throw new Error(`Error conectando: ${error.message}`);
    }
  }

  private async disconnectDevice(address: string): Promise<void> {
    try {
      await execAsync(`bluetoothctl disconnect ${address}`);
      this.logger.debug(`Desconectado de ${address}`);
    } catch (error) {
      this.logger.warn(`Error desconectando: ${error.message}`);
    }
  }

  private async sendCommand(address: string, command: string): Promise<string> {
    try {
      // Usar rfcomm para enviar comandos OBD
      const { stdout } = await execAsync(
        `echo "${command}\\r" | timeout 2 rfcomm connect /dev/rfcomm0 ${address} 1`
      );
      return stdout.trim();
    } catch (error) {
      throw new Error(`Error enviando comando ${command}: ${error.message}`);
    }
  }

  // Parsers de datos OBD
  private parseRPM(value: string): number | null {
    try {
      const bytes = this.parseHexBytes(value);
      return ((bytes[0] * 256 + bytes[1]) / 4) || null;
    } catch {
      return null;
    }
  }

  private parseSpeed(value: string): number | null {
    try {
      const bytes = this.parseHexBytes(value);
      return bytes[0] || null;
    } catch {
      return null;
    }
  }

  private parsePercentage(value: string): number | null {
    try {
      const bytes = this.parseHexBytes(value);
      return (bytes[0] * 100) / 255 || null;
    } catch {
      return null;
    }
  }

  private parseTemp(value: string): number | null {
    try {
      const bytes = this.parseHexBytes(value);
      return bytes[0] - 40 || null;
    } catch {
      return null;
    }
  }

  private parseMAF(value: string): number | null {
    try {
      const bytes = this.parseHexBytes(value);
      return ((bytes[0] * 256 + bytes[1]) / 100) || null;
    } catch {
      return null;
    }
  }

  private parseVoltage(value: string): number | null {
    try {
      const bytes = this.parseHexBytes(value);
      return ((bytes[0] * 256 + bytes[1]) / 1000) || null;
    } catch {
      return null;
    }
  }

  private parseHexBytes(value: string): number[] {
    // Extraer bytes hex de la respuesta OBD
    const hex = value.replace(/\s/g, '').replace(/[^0-9A-Fa-f]/g, '');
    const bytes: number[] = [];
    for (let i = 0; i < hex.length; i += 2) {
      bytes.push(parseInt(hex.substr(i, 2), 16));
    }
    return bytes;
  }

  private delay(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}
