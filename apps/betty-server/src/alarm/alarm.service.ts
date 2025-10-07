import { Injectable, Logger } from '@nestjs/common';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class AlarmService {
  private readonly logger = new Logger(AlarmService.name);
  private isActive = false;

  constructor(private readonly notificationsService: NotificationsService) {}

  async trigger(data: Record<string, unknown>): Promise<void> {
    if (this.isActive) {
      try {
        await this.notificationsService.sendNotification({
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
      } catch (error) {
        this.logger.error('❌ Error enviando notificación:', error);
      }
    }
  }

  activate(): { success: boolean; message: string; status: string } {
    this.isActive = true;
    this.logger.log('Alarm activated');

    return {
      success: true,
      message: 'Alarm has been activated',
      status: 'active',
    };
  }

  deactivate(): { success: boolean; message: string; status: string } {
    this.isActive = false;
    this.logger.log('Alarm deactivated');

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
