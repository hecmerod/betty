import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerConfigModule } from './shared/config/throttler/throttler-config.module';
import { AuthModule } from './shared/auth/auth.module';
import { CameraModule } from './camera/camera.module';
import { AlarmModule } from './alarm/alarm.module';
import { NotificationsModule } from './notifications/notifications.module';
import { HealthModule } from './shared/health/health.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    ThrottlerConfigModule,
    AuthModule,
    CameraModule,
    AlarmModule,
    NotificationsModule,
    HealthModule,
  ],
})
export class AppModule {}
