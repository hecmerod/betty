import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import {
  BatchResponse,
  Message,
  MulticastMessage,
} from 'firebase-admin/messaging';

@Injectable()
export class FirebaseService implements OnModuleInit {
  private messaging: admin.messaging.Messaging;

  constructor(private configService: ConfigService) {}

  async onModuleInit() {
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
  }

  async sendToDevice(
    token: string,
    notification: { title: string; body: string },
    data?: { [key: string]: string }
  ): Promise<string> {
    const message: Message = {
      token,
      notification: {
        title: notification.title,
        body: notification.body,
      },
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
  }

  async sendToMultipleDevices(
    tokens: string[],
    notification: { title: string; body: string },
    data?: { [key: string]: string }
  ): Promise<BatchResponse> {
    const message: MulticastMessage = {
      tokens,
      notification: {
        title: notification.title,
        body: notification.body,
      },
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

    return response;
  }
}
