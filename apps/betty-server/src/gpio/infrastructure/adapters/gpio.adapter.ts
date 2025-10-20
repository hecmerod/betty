import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { exec } from 'child_process';
import { promisify } from 'util';
import { join } from 'path';
import { existsSync, readFileSync } from 'fs';

const execAsync = promisify(exec);

interface PinConfig {
  pin: number;
  direction: 'INPUT' | 'OUTPUT';
  initialValue?: number;
  description?: string;
}

interface PinsConfigFile {
  pins: PinConfig[];
}

@Injectable()
export class GpioAdapter implements OnModuleInit {
  private readonly logger = new Logger(GpioAdapter.name);
  private readonly scriptPath: string;
  private readonly pinConfigs: PinConfig[] = [];

  constructor(private configService: ConfigService) {
    const productionPath =
      this.configService.get<string>('GPIO_SCRIPT_PRODUCTION_PATH') ||
      '/app/scripts/gpio_control.py';
    const devPath =
      this.configService.get<string>('GPIO_SCRIPT_DEV_PATH') ||
      '../../../../scripts/gpio_control.py';

    const devFullPath = join(__dirname, devPath);

    this.scriptPath = existsSync(productionPath) ? productionPath : devFullPath;
    this.logger.log(`Using GPIO script at: ${this.scriptPath}`);

    // Cargar configuración de pines desde archivo JSON
    this.loadPinConfig();
  }

  async onModuleInit() {
    this.logger.log('Initializing GPIO pins...');
    await this.initializePins();
  }

  private loadPinConfig(): void {
    try {
      const configPath = join(__dirname, '../../config/pins.config.json');
      this.logger.log(`Loading pin configuration from: ${configPath}`);

      if (!existsSync(configPath)) {
        this.logger.warn(
          `Pin configuration file not found at ${configPath}. No pins will be initialized.`
        );
        return;
      }

      const configFile = readFileSync(configPath, 'utf-8');
      const config: PinsConfigFile = JSON.parse(configFile);

      if (!config.pins || !Array.isArray(config.pins)) {
        this.logger.warn('Invalid pin configuration format');
        return;
      }

      this.pinConfigs.push(...config.pins);

      this.logger.log(`Loaded ${config.pins.length} pin configurations:`);
      config.pins.forEach((pinConfig) => {
        this.logger.log(
          `  Pin ${pinConfig.pin}: ${pinConfig.direction}${
            pinConfig.direction === 'OUTPUT'
              ? ` (initial: ${pinConfig.initialValue ?? 0})`
              : ''
          }${pinConfig.description ? ` - ${pinConfig.description}` : ''}`
        );
      });
    } catch (error) {
      this.logger.error(`Failed to load pin configuration: ${error.message}`);
    }
  }

  private async initializePins(): Promise<void> {
    for (const config of this.pinConfigs) {
      try {
        // Verificar el estado actual del pin
        const info = await this.getPinInfo(config.pin);
        const [currentDirection] = info.split('|');

        if (currentDirection !== config.direction) {
          this.logger.log(
            `Pin ${config.pin} is ${currentDirection}, reconfiguring to ${config.direction}...`
          );
          await this.configurePin(
            config.pin,
            config.direction,
            config.initialValue
          );
        } else if (
          config.direction === 'OUTPUT' &&
          config.initialValue !== undefined
        ) {
          // Si es OUTPUT, asegurarse de que tiene el valor inicial correcto
          this.logger.log(
            `Pin ${config.pin} already configured as OUTPUT, setting initial value to ${config.initialValue}`
          );
          await this.setPin(config.pin, config.initialValue === 1);
        } else {
          this.logger.log(
            `Pin ${config.pin} already configured correctly as ${config.direction}`
          );
        }
      } catch (error) {
        this.logger.error(
          `Failed to initialize pin ${config.pin}: ${error.message}`
        );
      }
    }

    this.logger.log('GPIO pins initialization completed');
  }

  private async configurePin(
    pin: number,
    direction: 'INPUT' | 'OUTPUT',
    initialValue?: number
  ): Promise<void> {
    const directionLower = direction.toLowerCase();
    const command =
      initialValue !== undefined
        ? `python3 ${this.scriptPath} configure ${pin} ${directionLower} ${initialValue}`
        : `python3 ${this.scriptPath} configure ${pin} ${directionLower}`;

    const { stdout } = await execAsync(command);
    this.logger.log(stdout.trim());
  }

  private async getPinInfo(pin: number): Promise<string> {
    const command = `python3 ${this.scriptPath} info ${pin}`;
    const { stdout } = await execAsync(command);
    return stdout.trim();
  }

  async setPin(pin: number, state: boolean): Promise<void> {
    this.logger.log(`Setting pin ${pin} to ${state ? 'HIGH' : 'LOW'}`);

    try {
      const value = state ? 1 : 0;
      const command = `python3 ${this.scriptPath} set ${pin} ${value}`;

      const { stdout } = await execAsync(command);
      this.logger.log(
        `Successfully set pin ${pin} to ${state ? 'HIGH' : 'LOW'}`
      );
      if (stdout) {
        this.logger.debug(stdout.trim());
      }
    } catch (error) {
      this.logger.error(
        `Failed to set pin ${pin} to ${state ? 'HIGH' : 'LOW'}: ${
          error.message
        }`
      );
      throw error;
    }
  }

  async getPin(pin: number): Promise<boolean> {
    this.logger.log(`Reading state of pin ${pin}`);

    try {
      const command = `python3 ${this.scriptPath} get ${pin}`;
      const { stdout } = await execAsync(command);

      const value = parseInt(stdout.trim());
      const state = value === 1;

      this.logger.log(`Pin ${pin} state: ${state ? 'HIGH' : 'LOW'}`);
      return state;
    } catch (error) {
      this.logger.error(`Failed to read pin ${pin}: ${error.message}`);
      throw error;
    }
  }
}
