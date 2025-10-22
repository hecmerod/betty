import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class BluetoothConfig {
  constructor(private configService: ConfigService) {}

  get isEnabled(): boolean {
    return this.configService.get<boolean>('BLUETOOTH_ENABLED', true);
  }

  get defaultScanDuration(): number {
    return this.configService.get<number>('BLUETOOTH_SCAN_DURATION', 10);
  }

  get autoReconnect(): boolean {
    return this.configService.get<boolean>('BLUETOOTH_AUTO_RECONNECT', true);
  }

  get reconnectInterval(): number {
    return this.configService.get<number>(
      'BLUETOOTH_RECONNECT_INTERVAL',
      30000
    );
  }

  get adapterName(): string {
    return this.configService.get<string>('BLUETOOTH_ADAPTER_NAME', 'hci0');
  }
}
