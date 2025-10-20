import { Injectable } from '@nestjs/common';
import { GpioAdapter } from '../../infrastructure/adapters/gpio.adapter';

@Injectable()
export class GetPinUseCase {
  constructor(private readonly gpioAdapter: GpioAdapter) {}

  async execute(pin: number): Promise<boolean> {
    return await this.gpioAdapter.getPin(pin);
  }
}
