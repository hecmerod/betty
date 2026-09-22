import { Injectable, Inject } from '@nestjs/common';
import { ALARM_REPOSITORY } from '../../../infrastructure/ioc/symbols';
import { AlarmRepository } from '../../../domain/repositories/alarm.repository';

@Injectable()
export class SetAlarmPasswordUseCase {
  constructor(
    @Inject(ALARM_REPOSITORY)
    private readonly alarmRepository: AlarmRepository
  ) {}

  async execute(password: string): Promise<{
    success: boolean;
    message: string;
    timestamp: string;
  }> {
    try {
      await this.alarmRepository.setPassword(password);

      return {
        success: true,
        message: 'Alarm password has been updated',
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        success: false,
        message:
          error instanceof Error
            ? error.message
            : 'Failed to update alarm password',
        timestamp: new Date().toISOString(),
      };
    }
  }
}
