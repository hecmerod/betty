import { Injectable, Logger } from '@nestjs/common';
import { FirebaseService } from './firebase.service';
import { SendNotificationDto, RegisterTokenDto } from './dto/notification.dto';

interface DeviceToken {
  token: string;
  userId?: string;
  platform?: string;
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
    try {
      const deviceToken: DeviceToken = {
        token: registerTokenDto.token,
        userId: registerTokenDto.userId,
        platform: registerTokenDto.platform || 'unknown',
        registeredAt: new Date(),
        lastUsed: new Date(),
      };

      this.deviceTokens.set(registerTokenDto.token, deviceToken);
      this.logger.log(
        `📱 Token registrado: ${registerTokenDto.token.substring(0, 20)}...`
      );

      return { success: true, message: 'Token registrado correctamente' };
    } catch (error) {
      this.logger.error('❌ Error registrando token:', error);
      return { success: false, message: 'Error registrando token' };
    }
  }

  async sendNotification(sendNotificationDto: SendNotificationDto) {
    try {
      const result = await this.firebaseService.sendToDevice(
        sendNotificationDto.token,
        sendNotificationDto.notification,
        sendNotificationDto.data
      );

      const deviceToken = this.deviceTokens.get(sendNotificationDto.token);
      if (deviceToken) {
        deviceToken.lastUsed = new Date();
      }

      return { success: true, messageId: result };
    } catch (error) {
      this.logger.error('❌ Error enviando notificación:', error);
      throw error;
    }
  }
}
