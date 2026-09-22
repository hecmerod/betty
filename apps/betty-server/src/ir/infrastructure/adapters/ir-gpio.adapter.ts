import { Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import { Gpio, type IGpio } from '@liminal-machines-co/gpio';
import { IrSignal } from '../../domain/entities/ir-signal.entity';
import { IIrPort } from '../../domain/ports/ir.port';
import { GpioConfig } from '../../../gpio/infrastructure/config/gpio.config';
import { NecParser } from '../protocol/nec.parser';

const FRAME_GAP_MS = 25;
const FRAME_GAP_US = 14000;
const RECONNECT_DELAY_MS = 5000;

@Injectable()
export class IrGpioAdapter implements IIrPort, OnModuleDestroy {
  private readonly logger = new Logger(IrGpioAdapter.name);
  private readonly parser = new NecParser();
  private gpio: IGpio | null = null;
  private onSignal?: (signal: IrSignal) => void;
  private reconnectTimer?: NodeJS.Timeout;
  private frameTimer?: NodeJS.Timeout;
  private shouldReconnect = false;
  private connecting = false;
  private pulses: number[] = [];
  private lastTimestampNs?: bigint;

  constructor(private readonly gpioConfig: GpioConfig) {}

  listen(onSignal: (signal: IrSignal) => void): void {
    this.clearReconnect();
    this.onSignal = onSignal;
    this.shouldReconnect = true;
    void this.connect();
  }

  stop(): void {
    this.shouldReconnect = false;
    this.clearReconnect();
    this.resetCapture();
    this.onSignal = undefined;
    void this.releaseGpio();
  }

  onModuleDestroy(): void {
    this.stop();
  }

  processEdge(_value: boolean, timestampNs: bigint): void {
    if (this.lastTimestampNs !== undefined) {
      const durationUs = Number(
        (timestampNs - this.lastTimestampNs) / BigInt(1000)
      );

      if (durationUs > FRAME_GAP_US) {
        this.flushFrame();
      } else if (durationUs > 0) {
        this.pulses.push(durationUs);
      }
    }

    this.lastTimestampNs = timestampNs;
    this.scheduleFrameFlush();
  }

  flushFrame(): IrSignal | null {
    this.clearFrameTimer();

    const pulses = this.pulses;
    this.pulses = [];
    this.lastTimestampNs = undefined;

    if (pulses.length === 0) return null;

    const decode = this.parser.parse(pulses);
    if (!decode) return null;

    const signal = new IrSignal(pulses, decode);
    this.onSignal?.(signal);

    return signal;
  }

  private async connect(): Promise<void> {
    if (this.connecting) return;

    this.connecting = true;

    try {
      await this.releaseGpio();

      const gpio = new Gpio();
      this.gpio = gpio;

      await gpio.pin(this.gpioConfig.irPin).setInput({
        pullup: true,
        edge: 'both',
        debounce: 0,
        onChange: (value, timestamp) => this.processEdge(value, timestamp),
      });

      if (!this.shouldReconnect) {
        await this.releaseGpio();
        return;
      }
    } catch (error) {
      this.logger.warn(
        `Failed to connect to IR receiver on GPIO ${this.gpioConfig.irPin}: ${
          error instanceof Error ? error.message : error
        }`
      );
      await this.releaseGpio();
      this.scheduleReconnect();
    } finally {
      this.connecting = false;
    }
  }

  private async releaseGpio(): Promise<void> {
    const gpio = this.gpio;
    this.gpio = null;

    if (!gpio) return;

    try {
      await gpio.release();
    } catch (error) {
      this.logger.warn(
        `Failed to release IR GPIO: ${
          error instanceof Error ? error.message : error
        }`
      );
    }
  }

  private scheduleFrameFlush(): void {
    this.clearFrameTimer();
    this.frameTimer = setTimeout(() => {
      this.frameTimer = undefined;
      this.flushFrame();
    }, FRAME_GAP_MS);
  }

  private resetCapture(): void {
    this.clearFrameTimer();
    this.pulses = [];
    this.lastTimestampNs = undefined;
  }

  private scheduleReconnect(): void {
    if (!this.shouldReconnect || this.reconnectTimer) return;

    this.reconnectTimer = setTimeout(() => {
      this.reconnectTimer = undefined;
      if (!this.shouldReconnect) return;

      void this.connect();
    }, RECONNECT_DELAY_MS);
  }

  private clearReconnect(): void {
    if (!this.reconnectTimer) return;

    clearTimeout(this.reconnectTimer);
    this.reconnectTimer = undefined;
  }

  private clearFrameTimer(): void {
    if (!this.frameTimer) return;

    clearTimeout(this.frameTimer);
    this.frameTimer = undefined;
  }
}
