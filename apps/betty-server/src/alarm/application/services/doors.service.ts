import { Inject, Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { GPIO_ADAPTER } from '../../../gpio/infrastructure/ioc/gpio.symbols';
import { IGpioPort } from '../../../gpio/domain/ports/gpio.port';
import { TriggerAlarmUseCase } from '../use-cases/trigger-alarm/trigger-alarm.use-case';
import { SENSOR_REPOSITORY } from '../../infrastructure/ioc/symbols';
import { SensorRepository } from '../../domain/repositories/sensor.repository';
import { SensorType } from '../../domain/entities/sensor.entity';

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

const PIN_TO_SENSOR: Record<DoorPin, SensorType> = {
  [DoorPin.CLARABOYAS]: 'door_claraboyas',
  [DoorPin.PUERTA_TRASERA]: 'door_trasera',
  [DoorPin.PUERTA_LATERAL]: 'door_lateral',
  [DoorPin.PUERTAS_DELANTERAS]: 'door_delanteras',
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
    @Inject() private readonly triggerAlarmUseCase: TriggerAlarmUseCase,
    @Inject(SENSOR_REPOSITORY)
    private readonly sensorRepository: SensorRepository
  ) {}

  async onModuleInit() {
    for (const pin of this.DOOR_PINS) {
      const sensorId = PIN_TO_SENSOR[pin];
      const isListening = await this.sensorRepository.isListening(sensorId);

      if (isListening) this.startDoorMonitoring(pin);
    }
  }

  async enableMonitoring(sensorId: SensorType): Promise<void> {
    const pin = this.getSensorPin(sensorId);
    const isListening = await this.sensorRepository.isListening(sensorId);

    if (isListening) return;

    await this.sensorRepository.enableListening(sensorId);
    this.startDoorMonitoring(pin);
  }

  async disableMonitoring(sensorId: SensorType): Promise<void> {
    const pin = this.getSensorPin(sensorId);
    const isListening = await this.sensorRepository.isListening(sensorId);

    if (!isListening) return;

    await this.sensorRepository.disableListening(sensorId);
    this.stopDoorMonitoring(pin);
  }

  private startDoorMonitoring(pin: DoorPin): void {
    this.gpioAdapter.watchPin(
      pin,
      (eventType, state) => this.onDoorEvent(pin, eventType, state),
      (error) =>
        this.logger.error(`Door monitoring error on pin ${pin}: ${error}`)
    );
    this.logger.log(`Started monitoring for ${DOOR_NAMES[pin]}`);
  }

  private stopDoorMonitoring(pin: DoorPin): void {
    this.gpioAdapter.unwatchPin(pin);
    this.logger.log(`Stopped monitoring for ${DOOR_NAMES[pin]}`);
  }

  private async onDoorEvent(
    pin: DoorPin,
    eventType: string,
    state: boolean
  ): Promise<void> {
    const sensorId = PIN_TO_SENSOR[pin];
    const isListening = await this.sensorRepository.isListening(sensorId);

    if (!isListening) return;

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

  private getSensorPin(sensorId: SensorType): DoorPin {
    const entry = Object.entries(PIN_TO_SENSOR).find(
      ([, sensor]) => sensor === sensorId
    );

    if (!entry) throw new Error(`Invalid sensor ID: ${sensorId}`);

    return parseInt(entry[0]) as DoorPin;
  }
}
