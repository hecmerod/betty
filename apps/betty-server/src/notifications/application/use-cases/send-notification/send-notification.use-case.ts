import { Injectable, Inject } from '@nestjs/common';
import { FirebaseService } from '../../../infrastructure/adapters/firebase.service';
import { SendNotificationDto } from '../../../presentation/dto/notification.dto';
import { DeviceTokenRepository } from '../../../domain/repositories/device-token.repository';
import { DEVICE_TOKEN_REPOSITORY } from '../../../infrastructure/ioc/symbols';

export interface SendNotificationResponse {
  success: boolean;
  tokensUsed?: number;
}

@Injectable()
export class SendNotificationUseCase {
  constructor(
    private readonly firebaseService: FirebaseService,
    @Inject(DEVICE_TOKEN_REPOSITORY)
    private readonly deviceTokenRepository: DeviceTokenRepository
  ) {}

  async execute(
    sendNotificationDto: SendNotificationDto
  ): Promise<SendNotificationResponse> {
    if (process.env.NODE_ENV !== 'production') return { success: true, tokensUsed: 0 };

    const tokens = await this.deviceTokenRepository.getAll();

    if (tokens.length === 0) return { success: true, tokensUsed: 0 };

    await this.firebaseService.sendToMultipleDevices(
      tokens,
      sendNotificationDto.notification,
      sendNotificationDto.data
    );

    return { success: true, tokensUsed: tokens.length };
  }
}
