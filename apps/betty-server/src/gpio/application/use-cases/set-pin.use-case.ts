import { Injectable } from '@nestjs/common';
import { GpioAdapter } from '../../infrastructure/adapters/gpio.adapter';

@Injectable()
export class SetPinUseCase {
  constructor(private readonly gpioAdapter: GpioAdapter) {}

  async execute(pin: number, state: boolean): Promise<void> {
    await this.gpioAdapter.setPin(pin, state);
  }
}
