import { Injectable } from '@nestjs/common';
import { DeviceTokenRepository } from '../../domain/repositories/device-token.repository';
import { DeviceToken } from '../../domain/entities/device-token.entity';

@Injectable()
export class InMemoryDeviceTokenRepository implements DeviceTokenRepository {
  protected deviceTokens: Map<string, DeviceToken> = new Map();

  async save(deviceToken: DeviceToken): Promise<void> {
    this.deviceTokens.set(deviceToken.token, deviceToken);
  }

  async getAll(): Promise<string[]> {
    return Array.from(this.deviceTokens.keys());
  }
}
