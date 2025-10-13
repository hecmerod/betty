import { DeviceToken } from '../device-token.entity';

describe('DeviceToken', () => {
  it('should create a device token with valid data', () => {
    const token = 'valid-firebase-token';
    const deviceToken = new DeviceToken(token);

    expect(deviceToken.token).toBe(token);
    expect(deviceToken.registeredAt).toBeInstanceOf(Date);
    expect(deviceToken.lastUsed).toBeInstanceOf(Date);
    expect(deviceToken.userId).toBeUndefined();
    expect(deviceToken.platform).toBeUndefined();
  });

  it('should create a device token with all parameters', () => {
    const token = 'valid-firebase-token';
    const registeredAt = new Date('2023-01-01');
    const lastUsed = new Date('2023-01-02');
    const userId = 'user-123';
    const platform = 'android';

    const deviceToken = new DeviceToken(
      token,
      registeredAt,
      lastUsed,
      userId,
      platform
    );

    expect(deviceToken.token).toBe(token);
    expect(deviceToken.registeredAt).toBe(registeredAt);
    expect(deviceToken.lastUsed).toBe(lastUsed);
    expect(deviceToken.userId).toBe(userId);
    expect(deviceToken.platform).toBe(platform);
  });

  it('should throw error for empty token', () => {
    expect(() => new DeviceToken('')).toThrow('Token cannot be empty');
  });

  it('should throw error for whitespace-only token', () => {
    expect(() => new DeviceToken('   ')).toThrow('Token cannot be empty');
  });

  it('should throw error for token exceeding 255 characters', () => {
    const longToken = 'a'.repeat(256);
    expect(() => new DeviceToken(longToken)).toThrow(
      'Token length cannot exceed 255 characters'
    );
  });

  it('should update last used timestamp', () => {
    const deviceToken = new DeviceToken('valid-token');
    const originalLastUsed = deviceToken.lastUsed;

    // Wait a bit to ensure different timestamp
    setTimeout(() => {
      deviceToken.updateLastUsed();
      expect(deviceToken.lastUsed.getTime()).toBeGreaterThan(
        originalLastUsed.getTime()
      );
    }, 1);
  });

  it('should detect expired token', () => {
    const oldDate = new Date(Date.now() - 40 * 24 * 60 * 60 * 1000); // 40 days ago
    const deviceToken = new DeviceToken('valid-token', new Date(), oldDate);

    expect(deviceToken.isExpired()).toBe(true);
  });

  it('should detect non-expired token', () => {
    const recentDate = new Date(Date.now() - 10 * 24 * 60 * 60 * 1000); // 10 days ago
    const deviceToken = new DeviceToken('valid-token', new Date(), recentDate);

    expect(deviceToken.isExpired()).toBe(false);
  });

  it('should detect expiration with custom expiration time', () => {
    const twoDaysAgo = new Date(Date.now() - 2 * 24 * 60 * 60 * 1000);
    const deviceToken = new DeviceToken('valid-token', new Date(), twoDaysAgo);

    const oneDayInMs = 24 * 60 * 60 * 1000;
    expect(deviceToken.isExpired(oneDayInMs)).toBe(true);
  });

  it('should return correct JSON representation', () => {
    const token = 'test-token';
    const registeredAt = new Date('2023-01-01T10:00:00Z');
    const lastUsed = new Date('2023-01-02T10:00:00Z');
    const userId = 'user-123';
    const platform = 'ios';

    const deviceToken = new DeviceToken(
      token,
      registeredAt,
      lastUsed,
      userId,
      platform
    );
    const json = deviceToken.toJSON();

    expect(json).toEqual({
      token,
      registeredAt: registeredAt.toISOString(),
      lastUsed: lastUsed.toISOString(),
      userId,
      platform,
    });
  });

  it('should handle JSON representation with undefined optional fields', () => {
    const token = 'test-token';
    const deviceToken = new DeviceToken(token);
    const json = deviceToken.toJSON();

    expect(json.token).toBe(token);
    expect(json.userId).toBeUndefined();
    expect(json.platform).toBeUndefined();
    expect(typeof json.registeredAt).toBe('string');
    expect(typeof json.lastUsed).toBe('string');
  });
});
