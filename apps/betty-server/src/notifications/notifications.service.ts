import { Injectable, Logger } from '@nestjs/common';
import { FirebaseService } from './firebase.service';
import { SendNotificationDto, RegisterTokenDto } from './dto/notification.dto';

export interface DeviceToken {
  token: string;
  registeredAt: Date;
  lastUsed: Date;
}

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);
  private deviceTokens: Map<string, DeviceToken> = new Map();

  constructor(private firebaseService: FirebaseService) {}

  registerToken(registerTokenDto: RegisterTokenDto): {
    success: boolean;
    message: string;
  } {
    const deviceToken: DeviceToken = {
      token: registerTokenDto.token,
      registeredAt: new Date(),
      lastUsed: new Date(),
    };

    this.deviceTokens.set(registerTokenDto.token, deviceToken);

    return { success: true, message: 'Token registrado correctamente' };
  }

  async notifyAllDevices(sendNotificationDto: SendNotificationDto) {
    const tokens = [];
    this.deviceTokens.forEach((token) => tokens.push(token.token));

    if (tokens.length > 0)
      await this.firebaseService.sendToMultipleDevices(
        tokens,
        sendNotificationDto.notification,
        sendNotificationDto.data
      );

    return { success: true };
  }
}
