import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerConfigModule } from './shared/config/throttler/throttler-config.module';
import { AuthModule } from './shared/auth/auth.module';
import { AlarmModule } from './alarm/alarm.module';
import { NotificationsModule } from './notifications/notifications.module';
import { GpsModule } from './gps/gps.module';
import { GpioModule } from './gpio/gpio.module';
import { PrismaModule } from './shared/prisma/prisma.module';
import { BatteriesModule } from './batteries/batteries.module';
import { SshModule } from './ssh/ssh.module';
import { RedisModule } from './shared/redis/redis.module';
import { HealthModule } from './core/health/health.module';
import { ObdiiModule } from './obdii/obdii.module';
import { LoggerModule } from './core/logger/logger.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    ...(process.env.NODE_ENV === 'production' ? [ThrottlerConfigModule] : []),
    ThrottlerConfigModule,
    AuthModule,
    AlarmModule,
    NotificationsModule,
    GpsModule,
    GpioModule,
    HealthModule,
    PrismaModule,
    BatteriesModule,
    SshModule,
    RedisModule,
    ObdiiModule,
    LoggerModule,
  ],
})
export class AppModule {}
