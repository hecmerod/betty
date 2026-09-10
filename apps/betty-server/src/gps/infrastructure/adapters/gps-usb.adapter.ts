import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { exec } from 'child_process';
import { createReadStream, existsSync } from 'fs';
import { readdir, realpath } from 'fs/promises';
import { join } from 'path';
import { Readable } from 'stream';
import { promisify } from 'util';
import { GpsReading, IGpsPort } from '../../domain/ports/gps.port';
import { NmeaParser } from '../protocol/nmea.parser';

const execAsync = promisify(exec);

const SERIAL_BY_ID_DIR = '/dev/serial/by-id';
const GPS_DEVICE_NAME_PATTERN = /u-blox|ublox|gps|gnss/i;
const DEFAULT_BAUD_RATE = 9600;
const FALLBACK_DEVICE_PATH = '/dev/ttyACM0';

@Injectable()
export class GpsUsbAdapter implements IGpsPort, OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(GpsUsbAdapter.name);
  private readonly parser = new NmeaParser();
  private stream: Readable | null = null;
  private buffer = '';
  private lastFix: GpsReading | null = null;
  private reconnectTimer?: NodeJS.Timeout;
  private devicePath: string | null = null;
  private shouldReconnect = false;

  async onModuleInit(): Promise<void> {
    this.shouldReconnect = true;

    try {
      await this.connect();
    } catch (error) {
      this.logger.error(
        `Failed to connect to GPS USB: ${
          error instanceof Error ? error.message : error
        }`
      );
      this.scheduleReconnect();
    }
  }

  onModuleDestroy(): void {
    this.shouldReconnect = false;
    this.clearReconnect();
    this.detachStream();
  }

  async readLocation(): Promise<GpsReading> {
    if (!this.lastFix) throw new Error('No GPS fix available');

    return this.lastFix;
  }

  attachStream(stream: Readable): void {
    this.detachStream();
    this.stream = stream;

    stream.on('data', (chunk: string | Buffer) => {
      this.processChunk(chunk.toString());
    });

    stream.on('error', (error: Error) => {
      this.logger.error(`GPS serial stream error: ${error.message}`);
      this.scheduleReconnect();
    });

    stream.on('close', () => {
      this.logger.warn('GPS serial stream closed');
      this.scheduleReconnect();
    });
  }

  processChunk(chunk: string): void {
    this.buffer += chunk;
    const lines = this.buffer.split(/\r?\n/);
    this.buffer = lines.pop() ?? '';

    for (const line of lines) {
      this.handleLine(line);
    }
  }

  private handleLine(line: string): void {
    const update = this.parser.parse(line);
    if (
      !update?.hasFix ||
      update.latitude === undefined ||
      update.longitude === undefined
    )
      return;

    this.lastFix = {
      latitude: update.latitude,
      longitude: update.longitude,
      altitude: update.altitude ?? this.lastFix?.altitude,
      timestamp: update.timestamp ?? new Date(),
    };
  }

  private async connect(): Promise<void> {
    this.devicePath = await this.findDevice();
    await this.configureSerial(this.devicePath);

    const stream = createReadStream(this.devicePath, {
      encoding: 'utf8',
      highWaterMark: 1024,
    });

    this.attachStream(stream);
    this.logger.log(`Connected to GPS USB at ${this.devicePath}`);
  }

  private async findDevice(): Promise<string> {
    try {
      const entries = await readdir(SERIAL_BY_ID_DIR);
      const gpsEntry = entries.find((entry) =>
        GPS_DEVICE_NAME_PATTERN.test(entry)
      );

      if (gpsEntry) {
        return realpath(join(SERIAL_BY_ID_DIR, gpsEntry));
      }
    } catch (error) {
      this.logger.warn(
        `Could not scan ${SERIAL_BY_ID_DIR}: ${
          error instanceof Error ? error.message : error
        }`
      );
    }

    if (existsSync(FALLBACK_DEVICE_PATH)) return FALLBACK_DEVICE_PATH;

    throw new Error('GPS USB device not found');
  }

  private async configureSerial(devicePath: string): Promise<void> {
    try {
      await execAsync(
        `stty -F ${devicePath} ${DEFAULT_BAUD_RATE} raw -echo -echoe -echok clocal cread`
      );
    } catch (error) {
      this.logger.warn(
        `Could not configure serial port ${devicePath}: ${
          error instanceof Error ? error.message : error
        }`
      );
    }
  }

  private detachStream(): void {
    if (!this.stream) return;

    this.stream.removeAllListeners();
    this.stream.destroy();
    this.stream = null;
    this.buffer = '';
  }

  private scheduleReconnect(): void {
    if (!this.shouldReconnect || this.reconnectTimer) return;

    this.reconnectTimer = setTimeout(async () => {
      this.reconnectTimer = undefined;
      try {
        await this.connect();
      } catch (error) {
        this.logger.error(
          `GPS USB reconnect failed: ${
            error instanceof Error ? error.message : error
          }`
        );
        this.scheduleReconnect();
      }
    }, 5000);
  }

  private clearReconnect(): void {
    if (!this.reconnectTimer) return;

    clearTimeout(this.reconnectTimer);
    this.reconnectTimer = undefined;
  }
}
