import { Injectable, Logger } from '@nestjs/common';
import { exec, spawn, ChildProcess } from 'child_process';
import { promisify } from 'util';
import { GpioConfig } from '../config/gpio.config';
import { IGpioPort } from '../../domain/ports/gpio.port';

const execAsync = promisify(exec);

@Injectable()
export class GpioAdapter implements IGpioPort {
  private readonly logger = new Logger(GpioAdapter.name);
  private watchProcesses: Map<number, ChildProcess> = new Map();

  constructor(private readonly gpioConfig: GpioConfig) {}

  async setPin(pin: number, state: boolean): Promise<void> {
    const value = state ? 1 : 0;
    const command = `python3 ${this.gpioConfig.scriptPath} set ${pin} ${value}`;

    await execAsync(command);
  }

  async getPin(pin: number): Promise<boolean> {
    const command = `python3 ${this.gpioConfig.scriptPath} get ${pin}`;
    const { stdout } = await execAsync(command);

    const value = parseInt(stdout.trim());
    const state = value === 1;

    return state;
  }

  watchPin(
    pin: number,
    onEvent: (eventType: string, state: boolean) => void,
    onError?: (error: string) => void,
    onExit?: (code: number | null) => void
  ): void {
    const process = spawn('python3', [
      this.gpioConfig.scriptPath,
      'watch',
      pin.toString(),
    ]);
    this.watchProcesses.set(pin, process);

    process.stdout.on('data', (data) => {
      const output = data.toString().trim();
      const lines = output.split('\n');

      for (const line of lines) {
        if (line.startsWith('EVENT|')) {
          const [, eventType, value] = line.split('|');

          const state = value === '1';

          onEvent(eventType, state);
        }
      }
    });

    process.stderr.on('data', (data) => onError?.(data.toString()));

    process.on('exit', (code) => {
      this.watchProcesses.delete(pin);
      onExit?.(code);
    });
  }

  unwatchPin(pin: number): void {
    const process = this.watchProcesses.get(pin);

    if (process) {
      process.kill();
      this.watchProcesses.delete(pin);
    }
  }
}
