import { Injectable, Inject, OnModuleDestroy } from '@nestjs/common';
import { AlarmRepository } from '../../../domain/repositories/alarm.repository';
import { SendNotificationUseCase } from '../../../../notifications/application/use-cases/send-notification/send-notification.use-case';
import { ALARM_REPOSITORY } from '../../../infrastructure/ioc/symbols';
import { SetPinUseCase } from '../../../../gpio/application/use-cases/set-pin.use-case';

@Injectable()
export class TriggerAlarmUseCase implements OnModuleDestroy{
  constructor(
    @Inject(ALARM_REPOSITORY)
    private readonly alarmRepository: AlarmRepository,
    private readonly sendNotificationUseCase: SendNotificationUseCase,
    private readonly setPinUseCase: SetPinUseCase,
  ) {}

  private isAlarmSoundActive = false;
  private alarmTimer = 0;

  async execute(
    triggerData?: AlarmTriggerDataInput
  ): Promise<boolean> {
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

      if(!this.isAlarmSoundActive) this.alarmSoundController(false);
      else this.alarmTimer = 0;

      return true;
    } catch  {
      return false;
    }
  }

  async alarmSoundController(state: boolean) {
    this.isAlarmSoundActive = true;

    await this.setPinUseCase.execute(17, state)

    if(this.alarmTimer < 10) {
      this.alarmTimer++;
      setTimeout(() => this.alarmSoundController(!state), state ? 200 : 500);
    }
    
    await this.setPinUseCase.execute(17, true);
    this.isAlarmSoundActive = false;
  }

  async onModuleDestroy() {
    await this.setPinUseCase.execute(17, true);
  }
}

export interface AlarmTriggerDataInput {
  eventType: string;
  detectionType: string;
  confidence?: number;
  metadata?: Record<string, unknown>;
}

