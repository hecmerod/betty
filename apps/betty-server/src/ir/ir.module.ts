import { Module } from '@nestjs/common';
import { GpioModule } from '../gpio/gpio.module';
import { ListenIrSignalService } from './application/services/listen-ir-signal/listen-ir-signal.use-case';
import { IrGpioAdapter } from './infrastructure/adapters/ir-gpio.adapter';
import { IR_ADAPTER } from './infrastructure/ioc/symbols';

@Module({
  imports: [GpioModule],
  providers: [
    {
      provide: IR_ADAPTER,
      useClass: IrGpioAdapter,
    },
    ListenIrSignalService,
  ],
  exports: [ListenIrSignalService, IR_ADAPTER],
})
export class IrModule {}
