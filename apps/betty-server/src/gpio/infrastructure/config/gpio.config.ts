import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { join } from 'path';
import { existsSync, readFileSync } from 'fs';

export interface PinConfig {
  pin: number;
  direction: 'INPUT' | 'OUTPUT';
  initialValue?: number;
  description?: string;
}

interface PinsConfigFile {
  pins: PinConfig[];
}

@Injectable()
export class GpioConfig {
  private readonly _scriptPath: string;
  private readonly _pinConfigs: PinConfig[] = [];

  constructor(private configService: ConfigService) {
    this._scriptPath = this.resolveScriptPath();
    this._pinConfigs = this.loadPinConfigs();
  }

  get scriptPath(): string {
    return this._scriptPath;
  }

  get pinConfigs(): PinConfig[] {
    return this._pinConfigs;
  }

  private resolveScriptPath(): string {
    const productionPath = this.configService.get<string>(
      'GPIO_SCRIPT_PRODUCTION_PATH'
    );
    const devPath = this.configService.get<string>('GPIO_SCRIPT_DEV_PATH');

    const devFullPath = join(__dirname, devPath);

    return existsSync(productionPath) ? productionPath : devFullPath;
  }

  private loadPinConfigs(): PinConfig[] {
    try {
      const configPath = join(__dirname, '../config/pins.config.json');

      console.debug(configPath);
      if (!existsSync(configPath))
        throw new Error(`Pins configuration file not found at ${configPath}`);

      const configFile = readFileSync(configPath, 'utf-8');
      const config: PinsConfigFile = JSON.parse(configFile);

      if (!config.pins || !Array.isArray(config.pins))
        throw new Error('Invalid pin configuration format');

      return config.pins;
    } catch (error) {
      throw new Error(`Failed to load pin configuration: ${error.message}`);
    }
  }

  getPinConfig(pin: number): PinConfig | undefined {
    return this._pinConfigs.find((config) => config.pin === pin);
  }
}
