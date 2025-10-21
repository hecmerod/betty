import { Module } from '@nestjs/common';
import { GpioController } from './presentation/controllers/gpio.controller';
import { SetPinUseCase } from './application/use-cases/set-pin.use-case';
import { GetPinUseCase } from './application/use-cases/get-pin.use-case';
import { GpioAdapter } from './infrastructure/adapters/gpio.adapter';
import { GpioConfig } from './infrastructure/config/gpio.config';
import { GpioPinInitializer } from './infrastructure/services/gpio-pin-initializer.service';
import { GPIO_ADAPTER } from './infrastructure/ioc/gpio.symbols';

@Module({
  controllers: [GpioController],
  providers: [
    GpioConfig,
    GpioPinInitializer,
    {
      provide: GPIO_ADAPTER,
      useClass: GpioAdapter,
    },
    SetPinUseCase,
    GetPinUseCase,
  ],
  exports: [SetPinUseCase, GetPinUseCase, GPIO_ADAPTER],
})
export class GpioModule {}
