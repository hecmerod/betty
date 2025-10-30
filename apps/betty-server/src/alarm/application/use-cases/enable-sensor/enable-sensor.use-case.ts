import { Inject, Injectable } from '@nestjs/common';
import { SensorType } from '../../../domain/entities/sensor.entity';
import { DoorsService } from '../../services/doors.service';
import { MotionDetectionService } from '../../services/motion-detection.service';

export interface EnableSensorInput {
  sensorId: SensorType;
}

@Injectable()
export class EnableSensorUseCase {
  constructor(
    @Inject() private readonly doorsService: DoorsService,
    @Inject() private readonly motionDetectionService: MotionDetectionService
  ) {}

  async execute(input: EnableSensorInput): Promise<void> {
    const { sensorId } = input;

    if (sensorId === 'motion')
      await this.motionDetectionService.enableMonitoring();
    else if (sensorId.startsWith('door_'))
      await this.doorsService.enableMonitoring(sensorId);
    else throw new Error(`Invalid sensor ID: ${sensorId}`);
  }
}
