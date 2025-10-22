import {
  BluetoothDevice,
  BluetoothConnection,
} from '../entities/bluetooth-device.entity';

export interface IBluetoothAdapter {
  scanDevices(durationSeconds?: number): Promise<BluetoothDevice[]>;
  getPairedDevices(): Promise<BluetoothDevice[]>;
  pairDevice(deviceAddress: string): Promise<boolean>;
  unpairDevice(deviceAddress: string): Promise<boolean>;
  connectDevice(deviceAddress: string): Promise<BluetoothConnection>;
  disconnectDevice(deviceAddress: string): Promise<boolean>;
  getConnectedDevices(): Promise<BluetoothDevice[]>;
  isAdapterAvailable(): Promise<boolean>;
  powerOn(): Promise<boolean>;
  powerOff(): Promise<boolean>;
  getAdapterInfo(): Promise<{
    address: string;
    name: string;
    powered: boolean;
    discoverable: boolean;
    pairable: boolean;
  }>;
}
