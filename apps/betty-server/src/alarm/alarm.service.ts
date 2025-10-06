import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class AlarmService {
  private readonly logger = new Logger(AlarmService.name);
  private isActive = false;

  trigger(data: Record<string, unknown>): { triggered: boolean } {
    if (this.isActive) this.logger.log('Alarm triggered with data:', data);

    return { triggered: this.isActive };
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
