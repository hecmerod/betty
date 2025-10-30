import { Inject, Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { GPIO_ADAPTER } from '../../../gpio/infrastructure/ioc/gpio.symbols';
import { IGpioPort } from '../../../gpio/domain/ports/gpio.port';
import { TriggerAlarmUseCase } from '../../../alarm/application/use-cases/trigger-alarm/trigger-alarm.use-case';

enum DoorPin {
  CLARABOYAS = 27,
  PUERTA_TRASERA = 22,
  PUERTA_LATERAL = 5,
  PUERTAS_DELANTERAS = 6,
}

const DOOR_NAMES: Record<DoorPin, string> = {
  [DoorPin.CLARABOYAS]: 'Claraboyas',
  [DoorPin.PUERTA_TRASERA]: 'Puerta trasera',
  [DoorPin.PUERTA_LATERAL]: 'Puerta lateral',
  [DoorPin.PUERTAS_DELANTERAS]: 'Puertas delanteras',
};

@Injectable()
export class DoorsService implements OnModuleInit {
  private readonly logger = new Logger(DoorsService.name);
  private readonly DOOR_PINS = [
    DoorPin.CLARABOYAS,
    DoorPin.PUERTA_TRASERA,
    DoorPin.PUERTA_LATERAL,
    DoorPin.PUERTAS_DELANTERAS,
  ];

  constructor(
    @Inject(GPIO_ADAPTER) private readonly gpioAdapter: IGpioPort,
    @Inject() private readonly triggerAlarmUseCase: TriggerAlarmUseCase
  ) {}

  onModuleInit() {
    this.startDoorMonitoring();
  }

  private startDoorMonitoring(): void {
    this.DOOR_PINS.forEach((pin) => {
      this.gpioAdapter.watchPin(
        pin,
        (eventType, state) => this.onDoorEvent(pin, eventType, state),
        (error) =>
          this.logger.error(`Door monitoring error on pin ${pin}: ${error}`),
        (code) => {
          if (code !== 0 && code !== null) {
            this.logger.warn(
              `Door monitoring process for pin ${pin} exited with code ${code}`
            );
          }
        }
      );
    });
  }

  private async onDoorEvent(
    pin: DoorPin,
    eventType: string,
    state: boolean
  ): Promise<void> {
    const doorName = DOOR_NAMES[pin];
    const doorState = state ? 'abierta' : 'cerrada';

    this.logger.log(`🚪 Door event detected: ${doorName} ${doorState}`);

    if (state && process.env.NODE_ENV === 'production')
      await this.triggerAlarmUseCase.execute({
        eventType: 'door_opened',
        detectionType: 'door',
        metadata: { doorName },
      });
  }
}
