import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { RegisterTokenUseCase } from './application/use-cases/register-token/register-token.use-case';
import { SendNotificationUseCase } from './application/use-cases/send-notification/send-notification.use-case';
import { NotificationsController } from './presentation/controllers/notifications.controller';
import { FirebaseService } from './infrastructure/adapters/firebase.service';
import { PrismaDeviceTokenRepository } from './infrastructure/repositories/prisma-device-token.repository';
import { DEVICE_TOKEN_REPOSITORY } from './infrastructure/ioc/symbols';

@Module({
  imports: [ConfigModule],
  controllers: [NotificationsController],
  providers: [
    {
      provide: DEVICE_TOKEN_REPOSITORY,
      useClass: PrismaDeviceTokenRepository,
    },
    RegisterTokenUseCase,
    SendNotificationUseCase,
    FirebaseService,
  ],
  exports: [
    DEVICE_TOKEN_REPOSITORY,
    RegisterTokenUseCase,
    SendNotificationUseCase,
    FirebaseService,
  ],
})
export class NotificationsModule {}
