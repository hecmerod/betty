import { Sensor, SensorType } from '../entities/sensor.entity';

export abstract class SensorRepository {
  abstract get(id: SensorType): Promise<Sensor>;
  abstract getAll(): Promise<Sensor[]>;
  abstract enableListening(id: SensorType): Promise<void>;
  abstract disableListening(id: SensorType): Promise<void>;
  abstract isListening(id: SensorType): Promise<boolean>;
}
