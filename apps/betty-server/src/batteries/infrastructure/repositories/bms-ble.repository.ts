import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { BmsRepository } from '../../domain/repositories/bms.repository';
import { BmsReading } from '../../domain/entities/bms-reading.entity';
import { BatteryId } from '../../domain/value-objects/battery-id.vo';
import { BmsBleClient } from '../ble/bms-ble.client';
import { Dp04sProtocolParser } from '../protocol/dp04s-protocol.parser';

interface BatteryConfig {
  macAddress: string;
  hciDeviceId: number;
}

@Injectable()
export class BmsBleRepository implements BmsRepository, OnModuleInit {
  private readonly logger = new Logger(BmsBleRepository.name);
  private readonly parser = new Dp04sProtocolParser();
  private readonly bleClients = new Map<number, BmsBleClient>();

  private readonly BATTERY_CONFIG: Record<number, BatteryConfig> = {
    1: {
      macAddress: 'A5:C2:37:2F:23:CE',
      hciDeviceId: 0, // hci0
    },
    2: {
      macAddress: 'A5:C2:37:40:48:56',
      hciDeviceId: 1, // hci1
    },
  };

  async onModuleInit() {
    for (const [batteryId, config] of Object.entries(this.BATTERY_CONFIG)) {
      try {
        const client = new BmsBleClient({
          deviceId: config.hciDeviceId,
          userChannel: true,
        });

        this.bleClients.set(Number(batteryId), client);
      } catch (error) {
        this.logger.error(
          `❌ Failed to initialize BLE client for battery ${batteryId}: ${error.message}`
        );
      }
    }
  }

  async readBms(batteryId: BatteryId): Promise<BmsReading> {
    const config = this.BATTERY_CONFIG[batteryId.getValue()];
    if (!config) {
      throw new Error(
        `No configuration found for battery ${batteryId.getValue()}`
      );
    }

    const bleClient = this.bleClients.get(batteryId.getValue());
    if (!bleClient) {
      throw new Error(
        `BLE client not initialized for battery ${batteryId.getValue()}`
      );
    }

    try {
      this.logger.log(
        `Reading battery ${batteryId.getValue()} on hci${config.hciDeviceId} (${
          config.macAddress
        })`
      );

      const rawData = await bleClient.readBms(config.macAddress);
      const parsedData = this.parser.parse(rawData);

      return new BmsReading(
        rawData.deviceAddress,
        batteryId.getValue(),
        parsedData.totalVoltage,
        parsedData.current,
        parsedData.remainingCapacity,
        parsedData.nominalCapacity,
        parsedData.cycles,
        parsedData.productionDate,
        parsedData.balanceStatus,
        parsedData.protectionStatus,
        parsedData.softwareVersion,
        parsedData.stateOfCharge,
        parsedData.mosfetStatus,
        parsedData.cellCount,
        parsedData.ntcCount,
        parsedData.temperatures,
        parsedData.cellVoltages,
        new Date()
      );
    } catch (error) {
      this.logger.error(
        `Failed to read battery ${batteryId.getValue()}: ${error.message}`
      );
      throw error;
    }
  }

  async readAllBms(): Promise<BmsReading[]> {
    const batteryIds = Object.keys(this.BATTERY_CONFIG).map((id) =>
      BatteryId.create(Number(id))
    );

    const readings = await Promise.allSettled(
      batteryIds.map((batteryId) => this.readBms(batteryId))
    );

    const successfulReadings: BmsReading[] = [];

    for (let i = 0; i < readings.length; i++) {
      const result = readings[i];
      const batteryId = batteryIds[i].getValue();

      if (result.status === 'fulfilled') {
        successfulReadings.push(result.value);
        this.logger.log(`✅ Successfully read battery ${batteryId}`);
      } else {
        this.logger.error(
          `❌ Failed to read battery ${batteryId}: ${result.reason.message}`
        );
      }
    }

    if (successfulReadings.length === 0) {
      throw new Error('Failed to read any battery');
    }

    this.logger.log(
      `Read ${successfulReadings.length} of ${batteryIds.length} batteries`
    );

    return successfulReadings;
  }
}
