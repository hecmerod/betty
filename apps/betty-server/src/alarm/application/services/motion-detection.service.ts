import { Inject, Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { GPIO_ADAPTER } from '../../../gpio/infrastructure/ioc/gpio.symbols';
import { IGpioPort } from '../../../gpio/domain/ports/gpio.port';
import { SendNotificationUseCase } from '../../../notifications/application/use-cases/send-notification/send-notification.use-case';

@Injectable()
export class MotionDetectionService implements OnModuleInit {
  private readonly logger = new Logger(MotionDetectionService.name);
  private readonly MOTION_SENSOR_PIN = 23;

  constructor(
    @Inject(GPIO_ADAPTER) private readonly gpioAdapter: IGpioPort,
    @Inject() private readonly sendNotificationUseCase: SendNotificationUseCase
  ) {}

  onModuleInit() {
    this.startMotionDetection();
  }

  private startMotionDetection(): void {
    this.gpioAdapter.watchPin(
      this.MOTION_SENSOR_PIN,
      (eventType, state) => this.onMotionEvent(eventType, state),
      (error) => this.logger.error(`Motion detection error: ${error}`),
      (code) => {
        if (code !== 0 && code !== null) {
          this.logger.warn(`Motion detection process exited with code ${code}`);
        }
      }
    );
  }

  private async onMotionEvent(
    eventType: string,
    state: boolean
  ): Promise<void> {
    this.logger.log(`🔔 Motion event detected: ${eventType} (${state})`);

    if (state && process.env.NODE_ENV === 'production') {
      await this.sendNotificationUseCase.execute({
        notification: {
          title: 'Movimiento detectado',
          body: 'Se ha detectado movimiento en el sensor IR',
        },
        data: { type: 'motion_detected' },
      });
    }
  }
}
