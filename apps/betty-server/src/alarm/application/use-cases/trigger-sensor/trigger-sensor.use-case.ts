import { Injectable, Inject } from '@nestjs/common';
import { ALARM_REPOSITORY } from '../../../infrastructure/ioc/symbols';
import { SensorType } from '../../../domain/entities/sensor.entity';
import { SensorState } from '../../../domain/enums/sensor-state.enum';
import { TriggerAlarmUseCase } from '../trigger-alarm/trigger-alarm.use-case';
import { GetSensorsStatusUseCase } from '../get-sensors-status/get-sensors-status.use-case';

@Injectable()
export class TriggerSensorUseCase {
  constructor(
    @Inject(ALARM_REPOSITORY)
    private readonly triggerAlarmUseCase: TriggerAlarmUseCase,
    private readonly getSensorsStatusUseCase: GetSensorsStatusUseCase
  ) {}

  async execute({state, sensorId}: TriggerSensorDataInput): Promise<boolean> {
    if(state == SensorState.CLOSED) return false;

    const sensors = await this.getSensorsStatusUseCase.execute();

    const isEnabled = sensors.find((sensor) => sensor.id === sensorId)?.isListening;

    //if(isEnabled) await this.triggerAlarmUseCase.execute();
    console.debug(state);
    return isEnabled?? false;  
  }
}

export interface TriggerSensorDataInput {
    sensorId: SensorType,
    state: SensorState
}

