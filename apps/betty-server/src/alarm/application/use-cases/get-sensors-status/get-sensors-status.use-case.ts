import { Inject, Injectable } from '@nestjs/common';
import { SENSOR_REPOSITORY } from '../../../infrastructure/ioc/symbols';
import { SensorRepository } from '../../../domain/repositories/sensor.repository';
import { Sensor } from '../../../domain/entities/sensor.entity';

export interface GetSensorsStatusOutput {
  sensors: Array<{
    id: string;
    isListening: boolean;
    createdAt: string;
    updatedAt: string;
  }>;
}

@Injectable()
export class GetSensorsStatusUseCase {
  constructor(
    @Inject(SENSOR_REPOSITORY)
    private readonly sensorRepository: SensorRepository
  ) {}

  async execute(): Promise<GetSensorsStatusOutput> {
    const sensors: Sensor[] = await this.sensorRepository.getAll();

    return {
      sensors: sensors.map((sensor) => sensor.toJSON()),
    };
  }
}
