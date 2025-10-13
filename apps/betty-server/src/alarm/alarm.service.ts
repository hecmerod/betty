import { Injectable } from '@nestjs/common';
import { SendNotificationUseCase } from '../notifications/application/use-cases/send-notification/send-notification.use-case';

@Injectable()
export class AlarmService {
  private isActive = false;

  constructor(
    private readonly sendNotificationUseCase: SendNotificationUseCase
  ) {}

  async trigger(data: Record<string, unknown>): Promise<void> {
    if (this.isActive) {
      await this.sendNotificationUseCase.execute({
        token: '',
        notification: {
          title: '🚨 BETTY ALARM',
          body: 'Persona detectada en tu hogar',
          imageUrl: '',
        },
        data: {
          type: 'alarm',
          timestamp: new Date().toISOString(),
          detectionType: (data?.event_type as string) || 'person',
        },
      });
    }
  }

  activate(): { success: boolean; message: string; status: string } {
    this.isActive = true;

    return {
      success: true,
      message: 'Alarm has been activated',
      status: 'active',
    };
  }

  deactivate(): { success: boolean; message: string; status: string } {
    this.isActive = false;

    return {
      success: true,
      message: 'Alarm has been deactivated',
      status: 'inactive',
    };
  }

  getStatus(): { active: boolean; status: string; timestamp: string } {
    return {
      active: this.isActive,
      status: this.isActive ? 'active' : 'inactive',
      timestamp: new Date().toISOString(),
    };
  }
}
