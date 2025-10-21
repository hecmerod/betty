import { Module } from '@nestjs/common';
import { MotionDetectionService } from './application/services/motion-detection.service';

import { GpioModule } from '../gpio/gpio.module';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [GpioModule, NotificationsModule],
  providers: [MotionDetectionService],
})
export class MotionDetectionModule {}
