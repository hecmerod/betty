import { Injectable, Inject } from '@nestjs/common';
import { ALARM_REPOSITORY } from '../../../infrastructure/ioc/symbols';
import { AlarmRepository } from '../../../domain/repositories/alarm.repository';

@Injectable()
export class GetAlarmStatusUseCase {
  constructor(
    @Inject(ALARM_REPOSITORY)
    private readonly alarmRepository: AlarmRepository
  ) {}

  async execute(): Promise<{
    active: boolean;
    status: string;
    timestamp: string;
    lastActivatedAt?: string;
    lastDeactivatedAt?: string;
    lastTriggeredAt?: string;
    activeDuration: number;
  }> {
    const alarm = await this.alarmRepository.get();
    const alarmData = alarm.toJSON();

    return {
      active: alarmData.isActive,
      status: alarmData.status,
      timestamp: new Date().toISOString(),
      lastActivatedAt: alarmData.lastActivatedAt,
      lastDeactivatedAt: alarmData.lastDeactivatedAt,
      lastTriggeredAt: alarmData.lastTriggeredAt,
      activeDuration: alarmData.activeDuration,
    };
  }
}
