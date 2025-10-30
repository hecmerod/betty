import { Module } from '@nestjs/common';
import { AlarmController } from './presentation/controllers/alarm.controller';
import { SensorsController } from './presentation/controllers/sensors.controller';
import { ActivateAlarmUseCase } from './application/use-cases/activate-alarm/activate-alarm.use-case';
import { DeactivateAlarmUseCase } from './application/use-cases/deactivate-alarm/deactivate-alarm.use-case';
import { TriggerAlarmUseCase } from './application/use-cases/trigger-alarm/trigger-alarm.use-case';
import { GetAlarmStatusUseCase } from './application/use-cases/get-alarm-status/get-alarm-status.use-case';
import { EnableSensorUseCase } from './application/use-cases/enable-sensor/enable-sensor.use-case';
import { DisableSensorUseCase } from './application/use-cases/disable-sensor/disable-sensor.use-case';
import { GetSensorsStatusUseCase } from './application/use-cases/get-sensors-status/get-sensors-status.use-case';
import { PrismaAlarmRepository } from './infrastructure/repositories/prisma-alarm.repository';
import { PrismaSensorRepository } from './infrastructure/repositories/prisma-sensor.repository';
import {
  ALARM_REPOSITORY,
  SENSOR_REPOSITORY,
} from './infrastructure/ioc/symbols';
import { NotificationsModule } from '../notifications/notifications.module';
import { GpioModule } from '../gpio/gpio.module';
import { DoorsService } from './application/services/doors.service';
import { MotionDetectionService } from './application/services/motion-detection.service';

@Module({
  imports: [NotificationsModule, GpioModule],
  controllers: [AlarmController, SensorsController],
  providers: [
    ActivateAlarmUseCase,
    DoorsService,
    MotionDetectionService,
    DeactivateAlarmUseCase,
    TriggerAlarmUseCase,
    GetAlarmStatusUseCase,
    EnableSensorUseCase,
    DisableSensorUseCase,
    GetSensorsStatusUseCase,
    {
      provide: ALARM_REPOSITORY,
      useClass: PrismaAlarmRepository,
    },
    {
      provide: SENSOR_REPOSITORY,
      useClass: PrismaSensorRepository,
    },
  ],
  exports: [
    ActivateAlarmUseCase,
    DeactivateAlarmUseCase,
    TriggerAlarmUseCase,
    GetAlarmStatusUseCase,
    EnableSensorUseCase,
    DisableSensorUseCase,
    GetSensorsStatusUseCase,
    ALARM_REPOSITORY,
    SENSOR_REPOSITORY,
  ],
})
export class AlarmModule {}
