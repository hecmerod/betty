import { Injectable, Inject } from '@nestjs/common';
import { ALARM_REPOSITORY } from '../../../infrastructure/ioc/symbols';
import { AlarmRepository } from '../../../domain/repositories/alarm.repository';

@Injectable()
export class ActivateAlarmUseCase {
  constructor(
    @Inject(ALARM_REPOSITORY)
    private readonly alarmRepository: AlarmRepository
  ) {}

  async execute(): Promise<{
    success: boolean;
    message: string;
    status?: string;
    timestamp: string;
  }> {
    try {
      await this.alarmRepository.activate();

      return {
        success: true,
        message: 'Alarm has been activated',
        status: 'active',
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        success: false,
        message:
          error instanceof Error ? error.message : 'Failed to activate alarm',
        timestamp: new Date().toISOString(),
      };
    }
  }
}
