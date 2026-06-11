import { Body, Controller, Get, Param, Patch, Post } from '@nestjs/common';
import { EnableSensorUseCase } from '../../application/use-cases/enable-sensor/enable-sensor.use-case';
import { DisableSensorUseCase } from '../../application/use-cases/disable-sensor/disable-sensor.use-case';
import { GetSensorsStatusUseCase } from '../../application/use-cases/get-sensors-status/get-sensors-status.use-case';
import { SensorType } from '../../domain/entities/sensor.entity';
import { SensorState } from '../../domain/enums/sensor-state.enum';
import { TriggerSensorUseCase } from '../../application/use-cases/trigger-sensor/trigger-sensor.use-case';

@Controller('sensors')
export class SensorsController {
  constructor(
    private readonly enableSensorUseCase: EnableSensorUseCase,
    private readonly disableSensorUseCase: DisableSensorUseCase,
    private readonly getSensorsStatusUseCase: GetSensorsStatusUseCase,
    private readonly triggerSensorUseCase: TriggerSensorUseCase
  ) {}

  @Get()
  async getStatus() {
    const sensors =  await this.getSensorsStatusUseCase.execute();

    return {
      sensors: sensors.map((sensor) => sensor.toJSON()),
    };
  }

  @Patch(':sensorId/enable')
  async enable(@Param('sensorId') sensorId: SensorType) {
    await this.enableSensorUseCase.execute({ sensorId });
    return { 
      message: `Sensor ${sensorId} enabled successfully`,
      sensorId,
      isListening: true
    };
  }

  @Patch(':sensorId/disable')
  async disable(@Param('sensorId') sensorId: SensorType) {
    await this.disableSensorUseCase.execute({ sensorId });
    return { 
      message: `Sensor ${sensorId} disabled successfully`,
      sensorId,
      isListening: false
    };
  }

  @Post(':sensorId/trigger')
  async updateState(@Param('sensorId') sensorId: SensorType, @Body() state: SensorState) {
    return await this.triggerSensorUseCase.execute({sensorId, state});    
  }
}
