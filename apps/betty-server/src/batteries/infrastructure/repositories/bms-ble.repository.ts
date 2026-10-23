import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  Observable,
  Subject,
  concat,
  defer,
  filter,
  firstValueFrom,
  from,
  timeout,
} from 'rxjs';
import { BmsRepository } from '../../domain/repositories/bms.repository';
import { BmsReading } from '../../domain/entities/bms-reading.entity';
import { BatteryId } from '../../domain/value-objects/battery-id.vo';
import {
  BmsBleClient,
  BmsConnectionStatus,
  BmsRawData,
} from '../ble/bms-ble.client';
import { Dp04sProtocolParser } from '../protocol/dp04s-protocol.parser';
import { releaseBmsFromBluez } from '../ble/release-bms-from-bluez';

interface BatteryConfig {
  macAddress: string;
  hciDeviceId: number;
}

const DEFAULT_BATTERY_CONFIG: Record<number, BatteryConfig> = {
  1: {
    macAddress: 'A5:C2:37:2F:23:CE',
    hciDeviceId: 0, // hci0 — Pi built-in
  },
  2: {
    macAddress: 'A5:C2:37:40:48:56',
    hciDeviceId: 1, // hci1 — USB dongle
  },
};

const DEFAULT_POLL_INTERVAL_MS = 2000;
const FIRST_READING_TIMEOUT_MS = 10000;

@Injectable()
export class BmsBleRepository
  implements BmsRepository, OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(BmsBleRepository.name);
  private readonly parser = new Dp04sProtocolParser();
  private readonly bleClients = new Map<number, BmsBleClient>();
  private readonly latestReadings = new Map<number, BmsReading>();
  private readonly readings$ = new Subject<BmsReading>();
  private readonly batteryConfig: Record<number, BatteryConfig>;
  private readonly pollIntervalMs: number;

  constructor(private readonly configService: ConfigService) {
    this.pollIntervalMs = Number(
      this.configService.get<string>(
        'BMS_POLL_INTERVAL_MS',
        String(DEFAULT_POLL_INTERVAL_MS)
      )
    );
    this.batteryConfig = this.loadBatteryConfig();
  }

  async onModuleInit() {
    const macs = Object.values(this.batteryConfig).map((c) => c.macAddress);
    await releaseBmsFromBluez(macs);

    for (const [id, config] of Object.entries(this.batteryConfig)) {
      const batteryId = Number(id);
      try {
        const client = new BmsBleClient({
          deviceId: config.hciDeviceId,
          macAddress: config.macAddress,
          userChannel: true,
          pollIntervalMs: this.pollIntervalMs,
        });

        client.on('data', (raw: BmsRawData) => this.onData(batteryId, raw));
        client.on('status', (status: BmsConnectionStatus) =>
          this.logger.log(`Battery ${batteryId} status: ${status}`)
        );

        this.bleClients.set(batteryId, client);
        client.start();
        this.logger.log(
          `Battery ${batteryId} BLE client started on hci${config.hciDeviceId} (${config.macAddress})`
        );
      } catch (error) {
        this.logger.error(
          `Failed to initialize BLE client for battery ${batteryId}: ${error.message}`
        );
      }
    }
  }

  async onModuleDestroy() {
    await Promise.allSettled(
      [...this.bleClients.values()].map((client) => client.stop())
    );
    this.readings$.complete();
  }

  async readBms(batteryId: BatteryId): Promise<BmsReading> {
    const id = batteryId.getValue();
    if (!this.batteryConfig[id]) {
      throw new Error(`No configuration found for battery ${id}`);
    }
    if (!this.bleClients.has(id)) {
      throw new Error(`BLE client not initialized for battery ${id}`);
    }

    const cached = this.latestReadings.get(id);
    if (cached) return cached;

    try {
      return await firstValueFrom(
        this.readings$.pipe(
          filter((reading) => reading.batteryId === id),
          timeout(FIRST_READING_TIMEOUT_MS)
        )
      );
    } catch {
      throw new Error(
        `No reading available yet for battery ${id} (status: ${this.bleClients
          .get(id)
          ?.getStatus()})`
      );
    }
  }

  async readAllBms(): Promise<BmsReading[]> {
    const ids = Object.keys(this.batteryConfig).map(Number);

    const readings = await Promise.allSettled(
      ids.map((id) => this.readBms(BatteryId.create(id)))
    );

    const successfulReadings: BmsReading[] = [];
    readings.forEach((result, i) => {
      if (result.status === 'fulfilled') {
        successfulReadings.push(result.value);
      } else {
        this.logger.warn(
          `Failed to read battery ${ids[i]}: ${result.reason.message}`
        );
      }
    });

    if (successfulReadings.length === 0) {
      throw new Error('Failed to read any battery');
    }

    return successfulReadings;
  }

  watch(batteryId?: BatteryId): Observable<BmsReading> {
    const id = batteryId?.getValue();
    const matches = (reading: BmsReading) =>
      id === undefined || reading.batteryId === id;

    return defer(() =>
      concat(
        from([...this.latestReadings.values()].filter(matches)),
        this.readings$.pipe(filter(matches))
      )
    );
  }

  private onData(batteryId: number, raw: BmsRawData): void {
    try {
      const parsed = this.parser.parse(raw);
      const reading = new BmsReading(
        raw.deviceAddress,
        batteryId,
        parsed.totalVoltage,
        parsed.current,
        parsed.remainingCapacity,
        parsed.nominalCapacity,
        parsed.cycles,
        parsed.productionDate,
        parsed.balanceStatus,
        parsed.protectionStatus,
        parsed.softwareVersion,
        parsed.stateOfCharge,
        parsed.mosfetStatus,
        parsed.cellCount,
        parsed.ntcCount,
        parsed.temperatures,
        parsed.cellVoltages,
        new Date()
      );

      this.latestReadings.set(batteryId, reading);
      this.readings$.next(reading);
    } catch (error) {
      this.logger.warn(
        `Failed to parse reading for battery ${batteryId}: ${error.message}`
      );
    }
  }

  private loadBatteryConfig(): Record<number, BatteryConfig> {
    const config: Record<number, BatteryConfig> = {};
    for (const [id, defaults] of Object.entries(DEFAULT_BATTERY_CONFIG)) {
      config[Number(id)] = {
        macAddress: this.configService.get<string>(
          `BMS_${id}_MAC`,
          defaults.macAddress
        ),
        hciDeviceId: Number(
          this.configService.get<string>(
            `BMS_${id}_HCI`,
            String(defaults.hciDeviceId)
          )
        ),
      };
    }
    return config;
  }
}
