import { Inject, Injectable } from '@nestjs/common';
import { IGpioPort } from '../../domain/ports/gpio.port';
import { GPIO_ADAPTER } from '../../infrastructure/ioc/gpio.symbols';

@Injectable()
export class GetPinUseCase {
  constructor(@Inject(GPIO_ADAPTER) private readonly gpioPort: IGpioPort) {}

  async execute(pin: number): Promise<boolean> {
    return await this.gpioPort.getPin(pin);
  }
}
