import { Module, OnModuleInit, Inject } from '@nestjs/common';
import { BluetoothConfig } from './infrastructure/config/bluetooth.config';
import { BluetoothAdapter } from './infrastructure/adapters/bluetooth.adapter';
import { BLUETOOTH_ADAPTER } from './infrastructure/ioc/bluetooth.symbols';
import { IBluetoothAdapter } from './domain/interfaces/bluetooth-adapter.interface';

@Module({
  providers: [
    BluetoothConfig,
    {
      provide: BLUETOOTH_ADAPTER,
      useClass: BluetoothAdapter,
    },
  ],
  exports: [BLUETOOTH_ADAPTER],
})
export class BluetoothModule implements OnModuleInit {
  constructor(
    private readonly config: BluetoothConfig,
    @Inject(BLUETOOTH_ADAPTER)
    private readonly adapter: IBluetoothAdapter
  ) {}

  async onModuleInit() {
    if (!this.config.isEnabled) return;

    await this.adapter.powerOn();
  }
}
