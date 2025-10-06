import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import { Message, MulticastMessage } from 'firebase-admin/messaging';

@Injectable()
export class FirebaseService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseService.name);
  private messaging: admin.messaging.Messaging;

  constructor(private configService: ConfigService) {}

  async onModuleInit() {
    try {
      const firebaseConfig = {
        projectId: this.configService.get<string>('FIREBASE_PROJECT_ID'),
        privateKey: this.configService
          .get<string>('FIREBASE_PRIVATE_KEY')
          ?.replace(/\\n/g, '\n'),
        clientEmail: this.configService.get<string>('FIREBASE_CLIENT_EMAIL'),
      };

      if (!admin.apps.length) {
        admin.initializeApp({
          credential: admin.credential.cert({
            projectId: firebaseConfig.projectId,
            privateKey: firebaseConfig.privateKey,
            clientEmail: firebaseConfig.clientEmail,
          }),
          projectId: firebaseConfig.projectId,
        });
      }

      this.messaging = admin.messaging();
    } catch (error) {
      this.logger.error('❌ Error inicializando Firebase:', error);
    }
  }

  private buildNotificationPayload(notification: any) {
    const payload: any = {
      title: notification.title,
      body: notification.body,
    };

    if (notification.imageUrl && notification.imageUrl.trim() !== '')
      payload.imageUrl = notification.imageUrl;

    return payload;
  }

  async sendToDevice(
    token: string,
    notification: any,
    data?: any
  ): Promise<string> {
    try {
      const message: Message = {
        token,
        notification: this.buildNotificationPayload(notification),
        data: data || {},
        android: {
          priority: 'high' as const,
          notification: {
            channelId: 'betty_alarm',
            priority: 'high' as const,
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
      };

      const response = await this.messaging.send(message);
      return response;
    } catch (error) {
      this.logger.error('❌ Error enviando notificación:', error);
      throw error;
    }
  }

  async sendToMultipleDevices(
    tokens: string[],
    notification: any,
    data?: any
  ): Promise<any> {
    try {
      const message: MulticastMessage = {
        tokens,
        notification: this.buildNotificationPayload(notification),
        data: data || {},
        android: {
          priority: 'high' as const,
          notification: {
            channelId: 'betty_alarm',
            priority: 'high' as const,
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
      };

      const response = await this.messaging.sendEachForMulticast(message);
      this.logger.log(
        `✅ Notificaciones enviadas: ${response.successCount}/${tokens.length}`
      );
      return response;
    } catch (error) {
      this.logger.error('❌ Error enviando notificaciones múltiples:', error);
      throw error;
    }
  }
}
