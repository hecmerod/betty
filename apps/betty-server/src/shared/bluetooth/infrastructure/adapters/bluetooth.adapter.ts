import { Injectable, Logger } from '@nestjs/common';
import { IBluetoothAdapter } from '../../domain/interfaces/bluetooth-adapter.interface';
import {
  BluetoothDevice,
  BluetoothConnection,
} from '../../domain/entities/bluetooth-device.entity';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

@Injectable()
export class BluetoothAdapter implements IBluetoothAdapter {
  private readonly logger = new Logger(BluetoothAdapter.name);

  async scanDevices(durationSeconds = 10): Promise<BluetoothDevice[]> {
    await execAsync('bluetoothctl --timeout 1 scan on');

    await new Promise((resolve) => setTimeout(resolve, durationSeconds * 1000));

    await execAsync('bluetoothctl --timeout 1 scan off');

    const { stdout } = await execAsync('bluetoothctl devices');
    const devices = this.parseDevicesList(stdout);

    return devices;
  }

  async getPairedDevices(): Promise<BluetoothDevice[]> {
    const { stdout } = await execAsync('bluetoothctl paired-devices');
    const devices = this.parseDevicesList(stdout);

    devices.forEach((device) => (device.paired = true));
    return devices;
  }

  async pairDevice(deviceAddress: string): Promise<boolean> {
    await execAsync(`bluetoothctl --timeout 30 pair ${deviceAddress}`);
    await execAsync(`bluetoothctl --timeout 10 trust ${deviceAddress}`);

    return true;
  }

  async unpairDevice(deviceAddress: string): Promise<boolean> {
    await execAsync(`bluetoothctl --timeout 10 remove ${deviceAddress}`);

    return true;
  }

  async connectDevice(deviceAddress: string): Promise<BluetoothConnection> {
    await execAsync(`bluetoothctl --timeout 30 connect ${deviceAddress}`);

    const deviceInfo = await this.getDeviceInfo(deviceAddress);

    const connection: BluetoothConnection = {
      deviceAddress,
      deviceName: deviceInfo?.name || 'Unknown',
      connectedAt: new Date(),
    };

    return connection;
  }

  async disconnectDevice(deviceAddress: string): Promise<boolean> {
    await execAsync(`bluetoothctl --timeout 10 disconnect ${deviceAddress}`);

    return true;
  }

  async getConnectedDevices(): Promise<BluetoothDevice[]> {
    const pairedDevices = await this.getPairedDevices();
    const connectedDevices: BluetoothDevice[] = [];

    for (const device of pairedDevices) {
      const info = await this.getDeviceInfo(device.address);
      if (info?.connected) {
        connectedDevices.push(info);
      }
    }

    return connectedDevices;
  }

  async isAdapterAvailable(): Promise<boolean> {
    const { stdout } = await execAsync('bluetoothctl show');

    return stdout.includes('Powered: yes');
  }

  async powerOn(): Promise<boolean> {
    await execAsync('bluetoothctl power on');

    this.logger.log('Bluetooth adapter powered on');

    return true;
  }

  async powerOff(): Promise<boolean> {
    await execAsync('bluetoothctl --timeout 10 power off');

    return true;
  }

  async getAdapterInfo(): Promise<{
    address: string;
    name: string;
    powered: boolean;
    discoverable: boolean;
    pairable: boolean;
  }> {
    const { stdout } = await execAsync('bluetoothctl show');

    const addressMatch = stdout.match(/Controller ([0-9A-F:]+)/i);
    const nameMatch = stdout.match(/Name: (.+)/);
    const poweredMatch = stdout.match(/Powered: (yes|no)/);
    const discoverableMatch = stdout.match(/Discoverable: (yes|no)/);
    const pairableMatch = stdout.match(/Pairable: (yes|no)/);

    return {
      address: addressMatch?.[1] || 'Unknown',
      name: nameMatch?.[1] || 'Unknown',
      powered: poweredMatch?.[1] === 'yes',
      discoverable: discoverableMatch?.[1] === 'yes',
      pairable: pairableMatch?.[1] === 'yes',
    };
  }

  private parseDevicesList(output: string): BluetoothDevice[] {
    const lines = output.split('\n').filter((line) => line.trim());
    const devices: BluetoothDevice[] = [];

    for (const line of lines) {
      const match = line.match(/Device ([0-9A-F:]+) (.+)/i);
      if (match) {
        devices.push({
          address: match[1],
          name: match[2],
          paired: false,
          connected: false,
        });
      }
    }

    return devices;
  }

  private async getDeviceInfo(
    deviceAddress: string
  ): Promise<BluetoothDevice | null> {
    const { stdout } = await execAsync(`bluetoothctl info ${deviceAddress}`);

    const nameMatch = stdout.match(/Name: (.+)/);
    const pairedMatch = stdout.match(/Paired: (yes|no)/);
    const connectedMatch = stdout.match(/Connected: (yes|no)/);
    const rssiMatch = stdout.match(/RSSI: (-?\d+)/);

    return {
      address: deviceAddress,
      name: nameMatch?.[1] || 'Unknown',
      paired: pairedMatch?.[1] === 'yes',
      connected: connectedMatch?.[1] === 'yes',
      rssi: rssiMatch ? parseInt(rssiMatch[1]) : undefined,
    };
  }
}
