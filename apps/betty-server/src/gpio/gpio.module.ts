import { Module } from '@nestjs/common';
import { GpioController } from './presentation/controllers/gpio.controller';
import { SetPinUseCase } from './application/use-cases/set-pin.use-case';
import { GetPinUseCase } from './application/use-cases/get-pin.use-case';
import { GpioAdapter } from './infrastructure/adapters/gpio.adapter';

@Module({
  controllers: [GpioController],
  providers: [SetPinUseCase, GetPinUseCase, GpioAdapter],
  exports: [SetPinUseCase, GetPinUseCase],
})
export class GpioModule {}
