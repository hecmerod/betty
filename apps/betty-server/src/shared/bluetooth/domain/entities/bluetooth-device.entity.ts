export interface BluetoothDevice {
  address: string;
  name: string;
  paired: boolean;
  connected: boolean;
  rssi?: number;
  class?: number;
  lastSeen?: Date;
}

export interface BluetoothConnection {
  deviceAddress: string;
  deviceName: string;
  connectedAt: Date;
  protocol?: string;
}
