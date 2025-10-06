import { Controller, Post, Body, Get } from '@nestjs/common';
import { AlarmService } from './alarm.service';

@Controller('alarm')
export class AlarmController {
  constructor(private readonly alarmService: AlarmService) {}

  @Get('status')
  getAlarmStatus() {
    return this.alarmService.getStatus();
  }

  @Post('activate')
  activateAlarm() {
    return this.alarmService.activate();
  }

  @Post('deactivate')
  deactivateAlarm() {
    return this.alarmService.deactivate();
  }

  @Post('trigger')
  triggerAlarm(@Body() body: Record<string, unknown>) {
    return this.alarmService.trigger(body);
  }
}
