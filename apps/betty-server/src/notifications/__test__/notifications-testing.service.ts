import { DeviceToken, NotificationsService } from '../notifications.service';
import { FirebaseService } from '../firebase.service';
import { TestingAvailableClass } from '../../shared/decorators/testing-available.decorator';

@TestingAvailableClass
export class NotificationsTestingService extends NotificationsService {
  constructor(firebaseService: FirebaseService) {
    super(firebaseService);
  }

  get _deviceTokens(): Map<string, DeviceToken> {
    return this['deviceTokens'] as Map<string, DeviceToken>;
  }

  clearDeviceTokens(): void {
    (this['deviceTokens'] as Map<string, DeviceToken>).clear();
  }
}
