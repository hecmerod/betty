import { Injectable, Inject } from '@nestjs/common';
import { AlarmRepository } from '../../../domain/repositories/alarm.repository';
import { ALARM_REPOSITORY } from '../../../infrastructure/ioc/symbols';

@Injectable()
export class DeactivateAlarmUseCase {
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
      await this.alarmRepository.deactivate();

      return {
        success: true,
        message: 'Alarm has been deactivated',
        status: 'inactive',
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        success: false,
        message:
          error instanceof Error ? error.message : 'Failed to deactivate alarm',
        timestamp: new Date().toISOString(),
      };
    }
  }
}
