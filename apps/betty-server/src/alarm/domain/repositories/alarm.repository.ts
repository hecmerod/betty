import { Alarm } from '../entities/alarm.entity';

export abstract class AlarmRepository {
  abstract activate(): Promise<void>;
  abstract deactivate(): Promise<void>;
  abstract get(): Promise<Alarm>;
  abstract setPassword(password: string): Promise<void>;
}
