import { AlarmService } from '../alarm.service';
import { SendNotificationUseCase } from '../../notifications/application/use-cases/send-notification/send-notification.use-case';
import { TestingAvailableClass } from '../../shared/decorators/testing-available.decorator';

@TestingAvailableClass
export class AlarmTestingService extends AlarmService {
  constructor(sendNotificationUseCase: SendNotificationUseCase) {
    super(sendNotificationUseCase);
  }

  get _isActive(): boolean {
    return this['isActive'] as boolean;
  }
}
