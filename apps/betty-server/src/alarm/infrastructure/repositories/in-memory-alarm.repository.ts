import { Injectable } from '@nestjs/common';
import { Alarm } from '../../domain/entities/alarm.entity';
import { AlarmRepository } from '../../domain/repositories/alarm.repository';
@Injectable()
export class InMemoryAlarmRepository extends AlarmRepository {
  private alarm: Alarm = new Alarm();

  async activate(): Promise<void> {
    this.alarm.activate();
  }

  async deactivate(): Promise<void> {
    this.alarm.deactivate();
  }

  async get(): Promise<Alarm> {
    return this.alarm;
  }
}
