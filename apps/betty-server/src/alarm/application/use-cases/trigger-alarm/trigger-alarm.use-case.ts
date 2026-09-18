import { Injectable, Inject, OnModuleDestroy } from '@nestjs/common';
import { AlarmRepository } from '../../../domain/repositories/alarm.repository';
import { SendNotificationUseCase } from '../../../../notifications/application/use-cases/send-notification/send-notification.use-case';
import { ALARM_REPOSITORY } from '../../../infrastructure/ioc/symbols';
import { SetPinUseCase } from '../../../../gpio/application/use-cases/set-pin.use-case';

const ALARM_COUNTER = 10;
const ALARM_DELAY_OFF = 500;
const ALARM_DELAY_ON = 200;

@Injectable()
export class TriggerAlarmUseCase implements OnModuleDestroy {
  constructor(
    @Inject(ALARM_REPOSITORY)
    private readonly alarmRepository: AlarmRepository,
    private readonly sendNotificationUseCase: SendNotificationUseCase,
    private readonly setPinUseCase: SetPinUseCase,
  ) { }

  private isAlarmSoundActive = false;
  private alarmTimer = 0;

  async execute(
    triggerData?: AlarmTriggerDataInput
  ): Promise<boolean> {
    const alarm = await this.alarmRepository.get();

    if (!alarm.isActive) return false;

    this.alarmTimer = 0;

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

      if (!this.isAlarmSoundActive) {
        this.isAlarmSoundActive = true;
        this.alarmSoundController(false);
      }
      else this.alarmTimer = 0;

      return true;
    } catch {
      return false;
    }
  }

  async alarmSoundController(state: boolean) {
    const alarm = await this.alarmRepository.get();

    if (!alarm.isActive) return;


    await this.setPinUseCase.execute(17, state)
    
    setTimeout(async() => {
      await this.setPinUseCase.execute(17, true);    

      if(state) this.alarmTimer++;

      if(this.alarmTimer < ALARM_COUNTER) this.alarmSoundController(!state);
      else this.isAlarmSoundActive = false;
      
    }, state ? ALARM_DELAY_ON : ALARM_DELAY_OFF);    

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

