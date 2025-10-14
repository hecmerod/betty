import { DeviceToken } from '../../../domain/entities/device-token.entity';
import { PrismaDeviceTokenRepository } from '../prisma-device-token.repository';

describe('PrismaDeviceTokenRepository', () => {
  let repository: PrismaDeviceTokenRepository;
  let mockPrismaService: any;

  beforeEach(() => {
    mockPrismaService = {
      deviceToken: {
        upsert: jest.fn(),
        findMany: jest.fn(),
      },
    };

    repository = new PrismaDeviceTokenRepository(mockPrismaService);
  });

  describe('save', () => {
    it('should save a device token using upsert', async () => {
      // Arrange
      const deviceToken = new DeviceToken('test-token-123');

      // Act
      await repository.save(deviceToken);

      // Assert
      expect(mockPrismaService.deviceToken.upsert).toHaveBeenCalledWith({
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
    });
  });

  describe('getAll', () => {
    it('should return all device tokens', async () => {
      // Arrange
      const mockTokens = [
        { token: 'token1' },
        { token: 'token2' },
        { token: 'token3' },
      ];
      mockPrismaService.deviceToken.findMany.mockResolvedValue(mockTokens);

      // Act
      const result = await repository.getAll();

      // Assert
      expect(result).toEqual(['token1', 'token2', 'token3']);
      expect(mockPrismaService.deviceToken.findMany).toHaveBeenCalledWith({
        select: { token: true },
      });
    });

    it('should return empty array when no tokens exist', async () => {
      // Arrange
      mockPrismaService.deviceToken.findMany.mockResolvedValue([]);

      // Act
      const result = await repository.getAll();

      // Assert
      expect(result).toEqual([]);
    });
  });
});
