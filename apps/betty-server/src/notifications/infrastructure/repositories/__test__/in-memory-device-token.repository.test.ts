import { InMemoryDeviceTokenTestingRepository } from './in-memory-device-token-testing.repository';
import { DeviceToken } from '../../../domain/entities/device-token.entity';

describe('InMemoryDeviceTokenRepository', () => {
  let repository: InMemoryDeviceTokenTestingRepository;

  beforeEach(() => {
    repository = new InMemoryDeviceTokenTestingRepository();
  });

  describe('save', () => {
    it('should save a device token', async () => {
      const deviceToken = new DeviceToken('test-token');

      await repository.save(deviceToken);

      const savedTokens = await repository.getAll();
      expect(savedTokens).toContain('test-token');
      expect(savedTokens).toHaveLength(1);
    });

    it('should overwrite existing token with same key', async () => {
      const deviceToken1 = new DeviceToken(
        'test-token',
        new Date('2023-01-01'),
        new Date('2023-01-01')
      );
      const deviceToken2 = new DeviceToken(
        'test-token',
        new Date('2023-01-02'),
        new Date('2023-01-02')
      );

      await repository.save(deviceToken1);
      await repository.save(deviceToken2);

      const tokens = await Array.from(repository._deviceTokens.values());
      const found = tokens.find((t) => t.token === 'test-token');
      expect(found?.registeredAt).toEqual(new Date('2023-01-02'));
      expect(tokens).toHaveLength(1);
    });
  });

  describe('getAll', () => {
    it('should return all token strings', async () => {
      await repository.save(new DeviceToken('token1'));
      await repository.save(new DeviceToken('token2'));
      await repository.save(new DeviceToken('token3'));

      const tokens = await repository.getAll();

      expect(tokens).toHaveLength(3);
      expect(tokens).toContain('token1');
      expect(tokens).toContain('token2');
      expect(tokens).toContain('token3');
    });

    it('should return empty array when no tokens', async () => {
      const tokens = await repository.getAll();

      expect(tokens).toHaveLength(0);
    });
  });

  describe('clear', () => {
    it('should clear all tokens', async () => {
      await repository.save(new DeviceToken('token1'));
      await repository.save(new DeviceToken('token2'));

      repository.clear();

      const tokens = await repository.getAll();
      expect(tokens).toHaveLength(0);
    });
  });

  describe('getInternalMap', () => {
    it('should return internal map for testing', async () => {
      const deviceToken = new DeviceToken('test-token');
      await repository.save(deviceToken);

      const tokens = repository._deviceTokens;

      expect(tokens.size).toBe(1);
      expect(tokens.has('test-token')).toBe(true);
    });
  });
});
