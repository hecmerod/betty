import { Inject, Injectable } from '@nestjs/common';
import { SENSOR_REPOSITORY } from '../../../infrastructure/ioc/symbols';
import { SensorRepository } from '../../../domain/repositories/sensor.repository';
import { Sensor } from '../../../domain/entities/sensor.entity';


@Injectable()
export class GetSensorsStatusUseCase {
  constructor(
    @Inject(SENSOR_REPOSITORY)
    private readonly sensorRepository: SensorRepository
  ) {}

  async execute(): Promise<Sensor[]> {
    const sensors: Sensor[] = await this.sensorRepository.getAll();

    return sensors;
  }
}
