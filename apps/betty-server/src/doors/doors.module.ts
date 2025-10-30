import { Module } from '@nestjs/common';

import { GpioModule } from '../gpio/gpio.module';
import { DoorsService } from './application/services/doors.service';
import { AlarmModule } from '../alarm/alarm.module';

@Module({
  imports: [GpioModule, AlarmModule],
  providers: [DoorsService],
})
export class DoorsModule {}
