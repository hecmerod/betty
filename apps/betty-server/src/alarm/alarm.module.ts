import { Module } from '@nestjs/common';
import { AlarmController } from './presentation/controllers/alarm.controller';
import { ActivateAlarmUseCase } from './application/use-cases/activate-alarm/activate-alarm.use-case';
import { DeactivateAlarmUseCase } from './application/use-cases/deactivate-alarm/deactivate-alarm.use-case';
import { TriggerAlarmUseCase } from './application/use-cases/trigger-alarm/trigger-alarm.use-case';
import { GetAlarmStatusUseCase } from './application/use-cases/get-alarm-status/get-alarm-status.use-case';
import { PrismaAlarmRepository } from './infrastructure/repositories/prisma-alarm.repository';
import { ALARM_REPOSITORY } from './infrastructure/ioc/symbols';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [NotificationsModule],
  controllers: [AlarmController],
  providers: [
    ActivateAlarmUseCase,
    DeactivateAlarmUseCase,
    TriggerAlarmUseCase,
    GetAlarmStatusUseCase,
    {
      provide: ALARM_REPOSITORY,
      useClass: PrismaAlarmRepository,
    },
  ],
  exports: [
    ActivateAlarmUseCase,
    DeactivateAlarmUseCase,
    TriggerAlarmUseCase,
    GetAlarmStatusUseCase,
    ALARM_REPOSITORY,
  ],
})
export class AlarmModule {}
