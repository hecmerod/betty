import { InMemoryDeviceTokenRepository } from '../in-memory-device-token.repository';
import { DeviceToken } from '../../../domain/entities/device-token.entity';

export class InMemoryDeviceTokenTestingRepository extends InMemoryDeviceTokenRepository {
  clear(): void {
    this.deviceTokens.clear();
  }

  get _deviceTokens(): Map<string, DeviceToken> {
    return this.deviceTokens;
  }
}
