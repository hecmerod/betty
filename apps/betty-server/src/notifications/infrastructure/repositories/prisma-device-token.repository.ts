import { Injectable } from '@nestjs/common';
import { DeviceTokenRepository } from '../../domain/repositories/device-token.repository';
import { DeviceToken } from '../../domain/entities/device-token.entity';
import { PrismaService } from '../../../shared/prisma/prisma.service';

@Injectable()
export class PrismaDeviceTokenRepository implements DeviceTokenRepository {
  constructor(private readonly prisma: PrismaService) {}

  async save(deviceToken: DeviceToken): Promise<void> {
    await this.prisma.deviceToken.upsert({
      where: { token: deviceToken.token },
      update: {
        lastUsed: deviceToken.lastUsed,
        userId: deviceToken.userId,
        platform: deviceToken.platform,
      },
      create: {
        token: deviceToken.token,
        registeredAt: deviceToken.registeredAt,
        lastUsed: deviceToken.lastUsed,
        userId: deviceToken.userId,
        platform: deviceToken.platform,
      },
    });
  }

  async getAll(): Promise<string[]> {
    const tokens = await this.prisma.deviceToken.findMany({
      select: { token: true },
    });

    return tokens.map((t) => t.token);
  }
}
