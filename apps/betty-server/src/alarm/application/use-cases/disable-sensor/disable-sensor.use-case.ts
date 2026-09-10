import { Inject, Injectable, forwardRef } from '@nestjs/common';
import { SensorType } from '../../../domain/entities/sensor.entity';
import { LocationService } from '../../../../gps/application/services/location.service';
import { DoorsService } from '../../services/doors.service';
import { MotionDetectionService } from '../../services/motion-detection.service';

export interface DisableSensorInput {
  sensorId: SensorType;
}

@Injectable()
export class DisableSensorUseCase {
  constructor(
    @Inject() private readonly doorsService: DoorsService,
    @Inject() private readonly motionDetectionService: MotionDetectionService,
    @Inject(forwardRef(() => LocationService))
    private readonly locationService: LocationService
  ) {}

  async execute(input: DisableSensorInput): Promise<void> {
    const { sensorId } = input;

    if (sensorId === 'motion')
      await this.motionDetectionService.disableMonitoring();
    else if (sensorId === 'location')
      await this.locationService.disableMonitoring();
    else if (sensorId.startsWith('door_'))
      await this.doorsService.disableMonitoring(sensorId);
    else throw new Error(`Invalid sensor ID: ${sensorId}`);
  }
}
