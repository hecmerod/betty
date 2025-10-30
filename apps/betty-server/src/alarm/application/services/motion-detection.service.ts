import { Inject, Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { GPIO_ADAPTER } from '../../../gpio/infrastructure/ioc/gpio.symbols';
import { IGpioPort } from '../../../gpio/domain/ports/gpio.port';
import { SENSOR_REPOSITORY } from '../../infrastructure/ioc/symbols';
import { SensorRepository } from '../../domain/repositories/sensor.repository';
import { TriggerAlarmUseCase } from '../use-cases/trigger-alarm/trigger-alarm.use-case';

@Injectable()
export class MotionDetectionService implements OnModuleInit {
  private readonly logger = new Logger(MotionDetectionService.name);
  private readonly MOTION_SENSOR_PIN = 23;

  constructor(
    @Inject(GPIO_ADAPTER) private readonly gpioAdapter: IGpioPort,
    @Inject() private readonly triggerAlarmUseCase: TriggerAlarmUseCase,
    @Inject(SENSOR_REPOSITORY)
    private readonly sensorRepository: SensorRepository
  ) {}

  async onModuleInit() {
    const isListening = await this.sensorRepository.isListening('motion');
    if (isListening) {
      this.startMotionDetection();
    }
  }

  async enableMonitoring(): Promise<void> {
    const isListening = await this.sensorRepository.isListening('motion');

    if (isListening) return;

    await this.sensorRepository.enableListening('motion');
    this.startMotionDetection();
  }

  async disableMonitoring(): Promise<void> {
    const isListening = await this.sensorRepository.isListening('motion');

    if (!isListening) return;

    await this.sensorRepository.disableListening('motion');
    this.stopMotionDetection();
  }

  private startMotionDetection(): void {
    this.gpioAdapter.watchPin(
      this.MOTION_SENSOR_PIN,
      (eventType, state) => this.onMotionEvent(eventType, state),
      (error) => this.logger.error(`Motion detection error: ${error}`)
    );
    this.logger.log('Motion detection monitoring started');
  }

  private stopMotionDetection(): void {
    this.gpioAdapter.unwatchPin(this.MOTION_SENSOR_PIN);
    this.logger.log('Motion detection monitoring stopped');
  }

  private async onMotionEvent(
    eventType: string,
    state: boolean
  ): Promise<void> {
    const isListening = await this.sensorRepository.isListening('motion');

    if (!isListening) return;

    this.logger.log(`🔔 Motion event detected: ${eventType} (${state})`);

    if (state && process.env.NODE_ENV === 'production') {
      await this.triggerAlarmUseCase.execute({
        eventType,
        detectionType: 'motion',
      });
    }
  }
}
