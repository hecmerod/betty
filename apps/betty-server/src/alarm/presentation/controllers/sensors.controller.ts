import { Controller, Get, Param, Patch } from '@nestjs/common';
import { EnableSensorUseCase } from '../../application/use-cases/enable-sensor/enable-sensor.use-case';
import { DisableSensorUseCase } from '../../application/use-cases/disable-sensor/disable-sensor.use-case';
import { GetSensorsStatusUseCase } from '../../application/use-cases/get-sensors-status/get-sensors-status.use-case';
import { SensorType } from '../../domain/entities/sensor.entity';

@Controller('sensors')
export class SensorsController {
  constructor(
    private readonly enableSensorUseCase: EnableSensorUseCase,
    private readonly disableSensorUseCase: DisableSensorUseCase,
    private readonly getSensorsStatusUseCase: GetSensorsStatusUseCase
  ) {}

  @Get()
  async getSensorsStatus() {
    return this.getSensorsStatusUseCase.execute();
  }

  @Patch(':sensorId/enable')
  async enableSensor(@Param('sensorId') sensorId: SensorType) {
    await this.enableSensorUseCase.execute({ sensorId });
    return { 
      message: `Sensor ${sensorId} enabled successfully`,
      sensorId,
      isListening: true
    };
  }

  @Patch(':sensorId/disable')
  async disableSensor(@Param('sensorId') sensorId: SensorType) {
    await this.disableSensorUseCase.execute({ sensorId });
    return { 
      message: `Sensor ${sensorId} disabled successfully`,
      sensorId,
      isListening: false
    };
  }
}
