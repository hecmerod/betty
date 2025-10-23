import { Module, OnModuleInit, Logger } from '@nestjs/common';
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
import { BluetoothModule } from './shared/bluetooth/bluetooth.module';
import { BatteriesModule } from './batteries/batteries.module';
import { MotionDetectionModule } from './motion-detection/motion-detection.module';
import { SendNotificationUseCase } from './notifications/application/use-cases/send-notification/send-notification.use-case';
import { SshModule } from './ssh/ssh.module';

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
    MotionDetectionModule,
    HealthModule,
    PrismaModule,
    BluetoothModule,
    BatteriesModule,
    SshModule,
  ],
})
export class AppModule implements OnModuleInit {
  private readonly logger = new Logger(AppModule.name);
  private readonly isProduction = process.env.NODE_ENV === 'production';

  constructor(
    private readonly sendNotificationUseCase: SendNotificationUseCase
  ) {}

  async onModuleInit() {
    if (!this.isProduction) return;

    try {
      await this.sendNotificationUseCase.execute({
        notification: {
          title: 'Betty iniciada',
          body: 'La Raspberry Pi se ha iniciado correctamente',
        },
        data: { type: 'system_startup' },
      });
    } catch (error) {
      this.logger.error(
        `❌ Failed to send startup notification: ${error.message}`
      );
    }
  }
}
