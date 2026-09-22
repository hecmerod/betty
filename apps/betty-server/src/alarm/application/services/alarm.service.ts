import { Inject, Injectable, OnModuleDestroy } from '@nestjs/common';
import { GPIO_ADAPTER } from '../../../gpio/infrastructure/ioc/gpio.symbols';
import { IGpioPort } from '../../../gpio/domain/ports/gpio.port';
import { ALARM_REPOSITORY } from '../../infrastructure/ioc/symbols';
import { AlarmRepository } from '../../domain/repositories/alarm.repository';

const ALARM_PIN = 17;
const ALARM_COUNTER = 10;
const ALARM_DELAY_OFF = 500;
const ALARM_DELAY_ON = 200;

@Injectable()
export class AlarmService implements OnModuleDestroy {
  private isAlarmSoundActive = false;
  private alarmTimer = 0;
  private alarmTimeout?: NodeJS.Timeout;

  constructor(
    @Inject(ALARM_REPOSITORY)
    private readonly alarmRepository: AlarmRepository,
    @Inject(GPIO_ADAPTER) private readonly gpioPort: IGpioPort
  ) {}

  activate(): void {
    this.alarmTimer = 0;

    if (this.isAlarmSoundActive) return;

    this.isAlarmSoundActive = true;
    void this.alarmSoundController(false);
  }

  async onModuleDestroy(): Promise<void> {
    this.stopSound();
    await this.gpioPort.setPin(ALARM_PIN, true);
  }

  private async alarmSoundController(state: boolean): Promise<void> {
    const alarm = await this.alarmRepository.get();

    if (!alarm.isActive) {
      this.stopSound();
      return;
    }

    await this.gpioPort.setPin(ALARM_PIN, state);

    this.alarmTimeout = setTimeout(async () => {
      await this.gpioPort.setPin(ALARM_PIN, true);

      if (state) this.alarmTimer++;

      if (this.alarmTimer < ALARM_COUNTER) {
        void this.alarmSoundController(!state);
        return;
      }

      this.stopSound();
    }, state ? ALARM_DELAY_ON : ALARM_DELAY_OFF);
  }

  stopSound(): void {
    this.isAlarmSoundActive = false;

    if (!this.alarmTimeout) return;

    clearTimeout(this.alarmTimeout);
    this.alarmTimeout = undefined;
  }
}
