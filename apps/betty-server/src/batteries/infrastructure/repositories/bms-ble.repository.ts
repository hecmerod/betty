import { Injectable, Logger } from '@nestjs/common';
import { BmsRepository } from '../../domain/repositories/bms.repository';
import { BmsReading } from '../../domain/entities/bms-reading.entity';
import { BatteryId } from '../../domain/value-objects/battery-id.vo';
import { BmsBleClient } from '../ble/bms-ble.client';
import { Dp04sProtocolParser } from '../protocol/dp04s-protocol.parser';

@Injectable()
export class BmsBleRepository implements BmsRepository {
  private readonly logger = new Logger(BmsBleRepository.name);
  private readonly bleClient = new BmsBleClient();
  private readonly parser = new Dp04sProtocolParser();

  private readonly BATTERY_MAC_MAP: Record<number, string> = {
    1: 'A5:C2:37:2F:23:CE',
    2: 'A5:C2:37:40:48:56',
  };

  async readBms(batteryId: BatteryId): Promise<BmsReading> {
    const macAddress = this.BATTERY_MAC_MAP[batteryId.getValue()];
    if (!macAddress)
      throw new Error(
        `No MAC address configured for battery ${batteryId.getValue()}`
      );

    try {
      const rawData = await this.bleClient.readBms(macAddress);
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
    const batteryIds = Object.keys(this.BATTERY_MAC_MAP).map((id) =>
      BatteryId.create(Number(id))
    );
    const readings: BmsReading[] = [];

    for (const batteryId of batteryIds) {
      try {
        const reading = await this.readBms(batteryId);
        readings.push(reading);
      } catch (error) {
        this.logger.error(
          `Failed to read battery ${batteryId.getValue()}, skipping: ${
            error.message
          }`
        );
      }
    }

    if (readings.length === 0) throw new Error('Failed to read any battery');

    return readings;
  }
}
