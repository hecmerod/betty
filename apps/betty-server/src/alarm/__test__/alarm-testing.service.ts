import { AlarmService } from '../alarm.service';
import { NotificationsService } from '../../notifications/notifications.service';
import { TestingAvailableClass } from '../../shared/decorators/testing-available.decorator';

@TestingAvailableClass
export class AlarmTestingService extends AlarmService {
  constructor(notificationsService: NotificationsService) {
    super(notificationsService);
  }

  get _isActive(): boolean {
    return this['isActive'] as boolean;
  }
}
