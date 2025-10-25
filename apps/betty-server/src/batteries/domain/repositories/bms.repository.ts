import { BmsReading } from '../entities/bms-reading.entity';
import { BatteryId } from '../value-objects/battery-id.vo';

export interface BmsRepository {
  readBms(batteryId: BatteryId): Promise<BmsReading>;
  readAllBms(): Promise<BmsReading[]>;
}
