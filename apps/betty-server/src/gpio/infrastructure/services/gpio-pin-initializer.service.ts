import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { exec } from 'child_process';
import { promisify } from 'util';
import { GpioConfig, PinConfig } from '../config/gpio.config';

const execAsync = promisify(exec);

@Injectable()
export class GpioPinInitializer implements OnModuleInit {
  private readonly logger = new Logger(GpioPinInitializer.name);

  constructor(private readonly gpioConfig: GpioConfig) {}

  async onModuleInit() {
    await this.initializeAllPins();
  }

  async initializeAllPins(): Promise<void> {
    for (const config of this.gpioConfig.pinConfigs) {
      await this.initializePin(config);
    }
  }

  private async initializePin(config: PinConfig): Promise<void> {
    try {
      const info = await this.getPinInfo(config.pin);
      const [currentDirection] = info.split('|');

      if (currentDirection !== config.direction) {
        await this.configurePin(
          config.pin,
          config.direction,
          config.initialValue
        );
      } else if (
        config.direction === 'OUTPUT' &&
        config.initialValue !== undefined
      ) {
        await this.setInitialValue(config.pin, config.initialValue);
      }
    } catch (error) {
      this.logger.error(
        `Failed to initialize pin ${config.pin}: ${error.message}`
      );
    }
  }

  private async getPinInfo(pin: number): Promise<string> {
    const command = `python3 ${this.gpioConfig.scriptPath} info ${pin}`;
    const { stdout } = await execAsync(command);
    return stdout.trim();
  }

  private async configurePin(
    pin: number,
    direction: 'INPUT' | 'OUTPUT',
    initialValue?: number
  ): Promise<void> {
    const directionLower = direction.toLowerCase();
    const command =
      initialValue !== undefined
        ? `python3 ${this.gpioConfig.scriptPath} configure ${pin} ${directionLower} ${initialValue}`
        : `python3 ${this.gpioConfig.scriptPath} configure ${pin} ${directionLower}`;

    await execAsync(command);
  }

  private async setInitialValue(pin: number, value: number): Promise<void> {
    const command = `python3 ${this.gpioConfig.scriptPath} set ${pin} ${value}`;
    await execAsync(command);
  }
}
