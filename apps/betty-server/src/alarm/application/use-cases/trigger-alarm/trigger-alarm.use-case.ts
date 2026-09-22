import { Injectable, Inject } from '@nestjs/common';
import { AlarmRepository } from '../../../domain/repositories/alarm.repository';
import { SendNotificationUseCase } from '../../../../notifications/application/use-cases/send-notification/send-notification.use-case';
import { ALARM_REPOSITORY } from '../../../infrastructure/ioc/symbols';
import { AlarmService } from '../../services/alarm.service';

@Injectable()
export class TriggerAlarmUseCase {
  constructor(
    @Inject(ALARM_REPOSITORY)
    private readonly alarmRepository: AlarmRepository,
    private readonly sendNotificationUseCase: SendNotificationUseCase,
    private readonly alarmService: AlarmService
  ) {}

  async execute(triggerData?: AlarmTriggerDataInput): Promise<boolean> {
    const alarm = await this.alarmRepository.get();

    if (!alarm.isActive) return false;

    try {
      await this.sendNotificationUseCase.execute({
        notification: {
          title: '🚨 BETTY ALARM',
          body: 'Persona detectada en tu hogar',
          imageUrl: '',
        },
        data: {
          type: 'alarm',
          timestamp: new Date().toISOString(),
          detectionType: triggerData?.detectionType || 'person',
          eventType: triggerData?.eventType || 'detection',
        },
      });

      this.alarmService.activate();

      return true;
    } catch {
      return false;
    }
  }
}

export interface AlarmTriggerDataInput {
  eventType: string;
  detectionType: string;
  confidence?: number;
  metadata?: Record<string, unknown>;
}
