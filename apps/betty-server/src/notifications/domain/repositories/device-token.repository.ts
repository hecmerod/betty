import { DeviceToken } from '../entities/device-token.entity';

export interface DeviceTokenRepository {
  save(deviceToken: DeviceToken): Promise<void>;

  getAll(): Promise<string[]>;
}
