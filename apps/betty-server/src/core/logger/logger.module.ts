import { Module } from '@nestjs/common';
import { CustomLogger } from './custom-logger';
import { NotificationsModule } from '../../notifications/notifications.module';

@Module({
  imports: [NotificationsModule],
  providers: [CustomLogger],
  exports: [CustomLogger],
})
export class LoggerModule {}
