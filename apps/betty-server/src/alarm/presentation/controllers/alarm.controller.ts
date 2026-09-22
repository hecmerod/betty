import { Body, Controller, Get, Post, ValidationPipe } from '@nestjs/common';
import { ActivateAlarmUseCase } from '../../application/use-cases/activate-alarm/activate-alarm.use-case';
import { DeactivateAlarmUseCase } from '../../application/use-cases/deactivate-alarm/deactivate-alarm.use-case';
import {
  AlarmTriggerDataInput,
  TriggerAlarmUseCase,
} from '../../application/use-cases/trigger-alarm/trigger-alarm.use-case';
import { GetAlarmPasswordUseCase } from '../../application/use-cases/get-alarm-password/get-alarm-password.use-case';
import { GetAlarmStatusUseCase } from '../../application/use-cases/get-alarm-status/get-alarm-status.use-case';
import { SetAlarmPasswordUseCase } from '../../application/use-cases/set-alarm-password/set-alarm-password.use-case';
import { Protected } from '../../../shared/auth/presentation/decorators/protected.decorator';
import { SetAlarmPasswordDto } from '../dto/set-alarm-password.dto';

@Controller('alarm')
export class AlarmController {
  constructor(
    private readonly activateAlarmUseCase: ActivateAlarmUseCase,
    private readonly deactivateAlarmUseCase: DeactivateAlarmUseCase,
    private readonly triggerAlarmUseCase: TriggerAlarmUseCase,
    private readonly getAlarmStatusUseCase: GetAlarmStatusUseCase,
    private readonly getAlarmPasswordUseCase: GetAlarmPasswordUseCase,
    private readonly setAlarmPasswordUseCase: SetAlarmPasswordUseCase
  ) {}

  @Get('status')
  async getAlarmStatus() {
    return this.getAlarmStatusUseCase.execute();
  }

  @Get('password')
  async getPassword() {
    return this.getAlarmPasswordUseCase.execute();
  }

  @Post('password')
  async setPassword(
    @Body(new ValidationPipe()) body: SetAlarmPasswordDto
  ) {
    return this.setAlarmPasswordUseCase.execute(body.password);
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
  async triggerAlarm(@Body() body?: AlarmTriggerDataInput) {
    return this.triggerAlarmUseCase.execute(body);
  }
}
