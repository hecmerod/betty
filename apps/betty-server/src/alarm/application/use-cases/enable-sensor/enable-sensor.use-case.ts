import { Inject, Injectable, forwardRef } from '@nestjs/common';
import { SensorType } from '../../../domain/entities/sensor.entity';
import { LocationService } from '../../../../gps/application/services/location.service';
import { DoorsService } from '../../services/doors.service';
import { MotionDetectionService } from '../../services/motion-detection.service';

export interface EnableSensorInput {
  sensorId: SensorType;
}

@Injectable()
export class EnableSensorUseCase {
  constructor(
    @Inject() private readonly doorsService: DoorsService,
    @Inject() private readonly motionDetectionService: MotionDetectionService,
    @Inject(forwardRef(() => LocationService))
    private readonly locationService: LocationService
  ) {}

  async execute(input: EnableSensorInput): Promise<void> {
    const { sensorId } = input;

    if (sensorId === 'motion')
      await this.motionDetectionService.enableMonitoring();
    else if (sensorId === 'location')
      await this.locationService.enableMonitoring();
    else if (sensorId.startsWith('door_'))
      await this.doorsService.enableMonitoring(sensorId);
    else throw new Error(`Invalid sensor ID: ${sensorId}`);
  }
}
