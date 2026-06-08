import { Controller, Post, Body, Get } from '@nestjs/common';
import { ActivateAlarmUseCase } from '../../application/use-cases/activate-alarm/activate-alarm.use-case';
import { DeactivateAlarmUseCase } from '../../application/use-cases/deactivate-alarm/deactivate-alarm.use-case';
import {
  AlarmTriggerData,
  TriggerAlarmUseCase,
} from '../../application/use-cases/trigger-alarm/trigger-alarm.use-case';
import { GetAlarmStatusUseCase } from '../../application/use-cases/get-alarm-status/get-alarm-status.use-case';
import { Protected } from '../../../shared/auth/presentation/decorators/protected.decorator';

@Controller('alarm')
export class AlarmController {
  constructor(
    private readonly activateAlarmUseCase: ActivateAlarmUseCase,
    private readonly deactivateAlarmUseCase: DeactivateAlarmUseCase,
    private readonly triggerAlarmUseCase: TriggerAlarmUseCase,
    private readonly getAlarmStatusUseCase: GetAlarmStatusUseCase
  ) {}

  @Get('status')
  async getAlarmStatus() {
    return this.getAlarmStatusUseCase.execute();
  }

  @Post('activate')
  async activateAlarm() {
    return this.activateAlarmUseCase.execute();
  }

  @Post('deactivate')
  async deactivateAlarm() {
    return this.deactivateAlarmUseCase.execute();
  }

  @Protected()
  @Post('trigger')
  async triggerAlarm(@Body() body: AlarmTriggerData) {
    return this.triggerAlarmUseCase.execute(body);
  }
}
