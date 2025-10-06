import { Module } from '@nestjs/common';
import { AlarmController } from './alarm.controller';
import { AlarmService } from './alarm.service';

@Module({
  controllers: [AlarmController],
  providers: [AlarmService],
  exports: [AlarmService],
})
export class AlarmModule {}
