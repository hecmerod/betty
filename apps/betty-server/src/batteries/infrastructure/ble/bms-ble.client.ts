/* eslint-disable @typescript-eslint/no-explicit-any */
import { Logger } from '@nestjs/common';
import { EventEmitter } from 'events';
const HCIBindings = require('@abandonware/noble/lib/hci-socket/bindings');
const Noble = require('@abandonware/noble/lib/noble');

export interface BmsRawData {
  deviceAddress: string;
  basicInfo: Buffer;
  cellVoltages: Buffer;
}

export type BmsConnectionStatus =
  | 'idle'
  | 'scanning'
  | 'connecting'
  | 'connected'
  | 'reconnecting'
  | 'stopped';

export interface BmsBleClientOptions {
  deviceId: number;
  macAddress: string;
  userChannel?: boolean;
  pollIntervalMs?: number;
}

const BMS_SERVICE_UUID = 'ff00';
const RX_CHAR_UUID = 'ff01';
const TX_CHAR_UUID = 'ff02';

const CMD_BASIC_INFO = Buffer.from([0xdd, 0xa5, 0x03, 0x00, 0xff, 0xfd, 0x77]);
const CMD_CELL_VOLTAGES = Buffer.from([
  0xdd, 0xa5, 0x04, 0x00, 0xff, 0xfc, 0x77,
]);

const FRAME_START = 0xdd;
const FRAME_END = 0x77;
const FRAME_HEADER_LENGTH = 4;
const FRAME_FOOTER_LENGTH = 3;

const SCAN_TIMEOUT_MS = 30000;
const CONNECT_TIMEOUT_MS = 30000;
const DISCOVERY_TIMEOUT_MS = 15000;
const COMMAND_TIMEOUT_MS = 5000;
const POST_SUBSCRIBE_DELAY_MS = 500;
const BACKOFF_MS = [1000, 2000, 5000, 10000, 30000];
const RESCAN_AFTER_FAILURES = 3;
const UNAUTHORIZED_RETRY_MS = 60000;
const BLE_SETUP_HINT =
  'Run from repo root: bash scripts/setup-ble-permissions.sh, then restart the server';

interface PendingCommand {
  name: string;
  buffer: Buffer;
  resolve: (frame: Buffer) => void;
  reject: (error: Error) => void;
  timer: NodeJS.Timeout;
}

/** Long-lived BMS link on one HCI adapter (one Noble stack per client). */
export class BmsBleClient extends EventEmitter {
  private static blePermissionsHintLogged = false;

  private readonly logger: Logger;
  private readonly noble: any;
  private readonly macAddress: string;
  private readonly pollIntervalMs: number;

  private status: BmsConnectionStatus = 'idle';
  private stopped = false;
  private running = false;
  private peripheral: any = null;
  private rxChar: any = null;
  private txChar: any = null;
  private pending: PendingCommand | null = null;
  private wakeSleep: (() => void) | null = null;
  private disconnectError: Error | null = null;

  constructor({
    deviceId,
    macAddress,
    userChannel,
    pollIntervalMs,
  }: BmsBleClientOptions) {
    super();
    this.macAddress = macAddress.toLowerCase();
    this.pollIntervalMs = pollIntervalMs ?? 2000;
    this.logger = new Logger(`${BmsBleClient.name}:hci${deviceId}`);
    this.noble = new Noble(
      new HCIBindings({
        deviceId,
        userChannel: userChannel ?? true,
        extended: false,
      })
    );
  }

  getStatus(): BmsConnectionStatus {
    return this.status;
  }

  start(): void {
    if (this.running) return;
    this.running = true;
    this.stopped = false;
    void this.run();
  }

  async stop(): Promise<void> {
    this.stopped = true;
    this.wakeSleep?.();
    this.failPending(new Error('Client stopped'));
    try {
      this.noble.stopScanning();
    } catch {
      /* empty */
    }
    await this.teardownConnection();
    this.setStatus('stopped');
  }

  private async run(): Promise<void> {
    let failures = 0;

    while (!this.stopped) {
      let lastError: Error | null = null;
      try {
        await this.waitForPoweredOn();

        if (!this.peripheral || failures >= RESCAN_AFTER_FAILURES) {
          this.setStatus('scanning');
          this.peripheral = await this.scan();
        }

        await this.connect();
        failures = 0;
        await this.pollLoop();
      } catch (error) {
        lastError = toError(error);
        if (!this.stopped) {
          const level =
            lastError.message === 'BLE adapter unauthorized'
              ? 'error'
              : 'warn';
          this.logger[level](`Connection error: ${lastError.message}`);
        }
      }

      await this.teardownConnection();
      if (this.stopped) break;

      failures++;
      let delay = BACKOFF_MS[Math.min(failures - 1, BACKOFF_MS.length - 1)];
      if (lastError?.message === 'BLE adapter unauthorized') {
        delay = UNAUTHORIZED_RETRY_MS;
      }
      this.setStatus('reconnecting');
      this.logger.log(`Reconnecting in ${delay} ms (attempt ${failures})`);
      await this.sleep(delay);
    }

    this.running = false;
  }

  private waitForPoweredOn(): Promise<void> {
    const initialState = this.noble.state ?? this.noble._state;
    const immediate = this.handleAdapterState(initialState);
    if (immediate) return immediate;

    return new Promise((resolve, reject) => {
      const onStateChange = (newState: string) => {
        const result = this.handleAdapterState(newState);
        if (!result) return;
        clearTimeout(timer);
        this.noble.removeListener('stateChange', onStateChange);
        result.then(resolve, reject);
      };
      this.noble.on('stateChange', onStateChange);

      const timer = setTimeout(() => {
        this.noble.removeListener('stateChange', onStateChange);
        reject(
          new Error(
            `BLE adapter not ready (state: ${this.noble.state ?? this.noble._state})`
          )
        );
      }, SCAN_TIMEOUT_MS);
    });
  }

  private handleAdapterState(state: string): Promise<void> | null {
    if (state === 'poweredOn') return Promise.resolve();
    if (state === 'unauthorized') {
      if (!BmsBleClient.blePermissionsHintLogged) {
        BmsBleClient.blePermissionsHintLogged = true;
        this.logger.error(`BLE adapter unauthorized. ${BLE_SETUP_HINT}`);
      }
      return Promise.reject(new Error('BLE adapter unauthorized'));
    }
    return null;
  }

  private scan(): Promise<any> {
    this.logger.log(`Scanning for ${this.macAddress}`);

    return new Promise((resolve, reject) => {
      const cleanup = () => {
        clearTimeout(timer);
        this.noble.removeListener('discover', onDiscover);
        try {
          this.noble.stopScanning();
        } catch {
          /* empty */
        }
      };

      const onDiscover = (peripheral: any) => {
        if (peripheral.address?.toLowerCase() !== this.macAddress) return;
        cleanup();
        this.logger.log(`Found ${this.macAddress}`);
        resolve(peripheral);
      };

      const timer = setTimeout(() => {
        cleanup();
        reject(new Error('Scan timeout'));
      }, SCAN_TIMEOUT_MS);

      this.noble.on('discover', onDiscover);
      this.noble.startScanning([], false);
    });
  }

  private async connect(): Promise<void> {
    const peripheral = this.peripheral;
    this.setStatus('connecting');
    this.disconnectError = null;
    try {
      this.noble.stopScanning();
    } catch {
      /* empty */
    }

    peripheral.removeListener('disconnect', this.onDisconnect);
    peripheral.once('disconnect', this.onDisconnect);

    await withTimeout(
      new Promise<void>((resolve, reject) => {
        peripheral.connect((err: any) =>
          err ? reject(toError(err)) : resolve()
        );
      }),
      CONNECT_TIMEOUT_MS,
      'Connect timeout',
      () => peripheral.cancelConnect()
    );

    const { characteristics } = await withTimeout<any>(
      peripheral.discoverSomeServicesAndCharacteristicsAsync(
        [BMS_SERVICE_UUID],
        [RX_CHAR_UUID, TX_CHAR_UUID]
      ),
      DISCOVERY_TIMEOUT_MS,
      'Characteristic discovery timeout'
    );

    this.rxChar = characteristics.find((c: any) => c.uuid === RX_CHAR_UUID);
    this.txChar = characteristics.find((c: any) => c.uuid === TX_CHAR_UUID);
    if (!this.rxChar || !this.txChar) {
      throw new Error('Required characteristics not found');
    }

    this.rxChar.on('data', this.onNotification);
    await this.rxChar.subscribeAsync();
    await this.sleep(POST_SUBSCRIBE_DELAY_MS);

    this.setStatus('connected');
    this.logger.log(`Connected to ${this.macAddress}`);
  }

  private async pollLoop(): Promise<void> {
    while (!this.stopped) {
      this.assertConnected();

      const basicInfo = await this.sendCommand(CMD_BASIC_INFO, 'Basic info');
      const cellVoltages = await this.sendCommand(
        CMD_CELL_VOLTAGES,
        'Cell voltages'
      );

      this.emit('data', {
        deviceAddress: this.peripheral.address.toUpperCase(),
        basicInfo,
        cellVoltages,
      } satisfies BmsRawData);

      await this.sleep(this.pollIntervalMs);
    }
  }

  private sendCommand(command: Buffer, name: string): Promise<Buffer> {
    this.assertConnected();

    return new Promise((resolve, reject) => {
      this.pending = {
        name,
        buffer: Buffer.alloc(0),
        resolve,
        reject,
        timer: setTimeout(() => {
          const bytes = this.pending?.buffer.length ?? 0;
          this.pending = null;
          reject(
            new Error(
              `${name} timeout${bytes > 0 ? ` (${bytes} bytes received)` : ''}`
            )
          );
        }, COMMAND_TIMEOUT_MS),
      };

      this.txChar.write(command, true, (err: any) => {
        if (err) this.failPending(toError(err));
      });
    });
  }

  private readonly onNotification = (data: Buffer) => {
    const pending = this.pending;
    if (!pending) return;

    pending.buffer = Buffer.concat([pending.buffer, data]);
    const frame = tryExtractJbdFrame(pending.buffer);
    if (!frame) return;

    clearTimeout(pending.timer);
    this.pending = null;

    if (frame[2] !== 0x00) {
      pending.reject(
        new Error(`${pending.name}: BMS error status 0x${frame[2].toString(16)}`)
      );
    } else {
      pending.resolve(frame);
    }
  };

  private readonly onDisconnect = (reason?: number) => {
    this.logger.warn(`Disconnected from ${this.macAddress} (reason ${reason})`);
    this.disconnectError = new Error('Peripheral disconnected');
    this.failPending(this.disconnectError);
    this.wakeSleep?.();
  };

  private assertConnected(): void {
    if (this.disconnectError) throw this.disconnectError;
  }

  private failPending(error: Error): void {
    const pending = this.pending;
    if (!pending) return;
    clearTimeout(pending.timer);
    this.pending = null;
    pending.reject(error);
  }

  private async teardownConnection(): Promise<void> {
    this.failPending(new Error('Connection closed'));

    if (this.rxChar) {
      this.rxChar.removeListener('data', this.onNotification);
      this.rxChar = null;
    }
    this.txChar = null;

    const peripheral = this.peripheral;
    if (!peripheral) return;
    peripheral.removeListener('disconnect', this.onDisconnect);

    if (peripheral.state === 'connecting') {
      peripheral.cancelConnect();
    } else if (peripheral.state === 'connected') {
      await withTimeout<void>(
        peripheral.disconnectAsync(),
        3000,
        'Disconnect timeout'
      ).catch(() => {
        /* empty */
      });
    }
  }

  private sleep(ms: number): Promise<void> {
    return new Promise((resolve) => {
      function done() {
        clearTimeout(timer);
        resolve();
      }
      const timer = setTimeout(done, ms);
      this.wakeSleep = () => {
        this.wakeSleep = null;
        done();
      };
    });
  }

  private setStatus(status: BmsConnectionStatus): void {
    if (this.status === status) return;
    this.status = status;
    this.emit('status', status);
  }
}

function tryExtractJbdFrame(buffer: Buffer): Buffer | null {
  const start = buffer.indexOf(FRAME_START);
  if (start < 0) return null;

  const frame = buffer.subarray(start);
  if (frame.length < FRAME_HEADER_LENGTH) return null;

  const payloadLength = frame[3];
  const totalLength =
    FRAME_HEADER_LENGTH + payloadLength + FRAME_FOOTER_LENGTH;
  if (frame.length < totalLength) return null;
  if (frame[totalLength - 1] !== FRAME_END) return null;

  return frame.subarray(0, totalLength);
}

function toError(err: unknown): Error {
  return err instanceof Error ? err : new Error(String(err));
}

function withTimeout<T>(
  promise: Promise<T>,
  ms: number,
  message: string,
  onTimeout?: () => void
): Promise<T> {
  return new Promise<T>((resolve, reject) => {
    const timer = setTimeout(() => {
      onTimeout?.();
      reject(new Error(message));
    }, ms);
    promise.then(
      (value) => {
        clearTimeout(timer);
        resolve(value);
      },
      (error) => {
        clearTimeout(timer);
        reject(toError(error));
      }
    );
  });
}
