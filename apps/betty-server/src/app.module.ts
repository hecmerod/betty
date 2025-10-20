import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerConfigModule } from './shared/config/throttler/throttler-config.module';
import { AuthModule } from './shared/auth/auth.module';
import { CameraModule } from './camera/camera.module';
import { AlarmModule } from './alarm/alarm.module';
import { NotificationsModule } from './notifications/notifications.module';
import { GpsModule } from './gps/gps.module';
import { TripsModule } from './trips/trips.module';
import { GpioModule } from './gpio/gpio.module';
import { HealthModule } from './shared/health/health.module';
import { PrismaModule } from './shared/prisma/prisma.module';

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
    GpsModule,
    TripsModule,
    GpioModule,
    HealthModule,
    PrismaModule,
  ],
})
export class AppModule {}
