import { Injectable, Inject } from '@nestjs/common';
import { ALARM_REPOSITORY } from '../../../infrastructure/ioc/symbols';
import { AlarmRepository } from '../../../domain/repositories/alarm.repository';

@Injectable()
export class GetAlarmPasswordUseCase {
  constructor(
    @Inject(ALARM_REPOSITORY)
    private readonly alarmRepository: AlarmRepository
  ) {}

  async execute(): Promise<{ password: string }> {
    const alarm = await this.alarmRepository.get();

    return { password: alarm.password };
  }
}
