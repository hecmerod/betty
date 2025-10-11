import { FirebaseService } from '../firebase.service';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

jest.mock('firebase-admin', () => ({
  apps: { length: 0 },
  initializeApp: jest.fn(),
  credential: {
    cert: jest.fn(),
  },
  messaging: jest.fn(() => ({
    send: jest.fn(),
    sendEachForMulticast: jest.fn(),
  })),
}));

describe('FirebaseService', () => {
  let service: FirebaseService;
  let mockConfigService: jest.Mocked<ConfigService>;
  let mockMessaging: jest.Mocked<admin.messaging.Messaging>;

  beforeEach(() => {
    mockConfigService = {
      get: jest.fn(),
    } as unknown as jest.Mocked<ConfigService>;

    mockMessaging = {
      send: jest.fn(),
      sendEachForMulticast: jest.fn(),
    } as unknown as jest.Mocked<admin.messaging.Messaging>;

    (admin.messaging as jest.Mock).mockReturnValue(mockMessaging);

    service = new FirebaseService(mockConfigService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('onModuleInit', () => {
    it('should initialize Firebase with correct configuration', async () => {
      mockConfigService.get
        .mockReturnValueOnce('test-project-id')
        .mockReturnValueOnce('test-private-key\\nwith-newlines')
        .mockReturnValueOnce('test@example.com');

      await service.onModuleInit();

      expect(mockConfigService.get).toHaveBeenCalledWith('FIREBASE_PROJECT_ID');
      expect(mockConfigService.get).toHaveBeenCalledWith(
        'FIREBASE_PRIVATE_KEY'
      );
      expect(mockConfigService.get).toHaveBeenCalledWith(
        'FIREBASE_CLIENT_EMAIL'
      );
      expect(admin.credential.cert).toHaveBeenCalledWith({
        projectId: 'test-project-id',
        privateKey: 'test-private-key\nwith-newlines',
        clientEmail: 'test@example.com',
      });
      expect(admin.initializeApp).toHaveBeenCalled();
    });

    it('should not reinitialize if Firebase app already exists', async () => {
      Object.defineProperty(admin.apps, 'length', { value: 1, writable: true });

      mockConfigService.get
        .mockReturnValueOnce('test-project-id')
        .mockReturnValueOnce('test-private-key')
        .mockReturnValueOnce('test@example.com');

      await service.onModuleInit();

      expect(admin.initializeApp).not.toHaveBeenCalled();

      Object.defineProperty(admin.apps, 'length', { value: 0, writable: true });
    });
  });

  describe('sendToDevice', () => {
    beforeEach(async () => {
      mockConfigService.get
        .mockReturnValueOnce('test-project-id')
        .mockReturnValueOnce('test-private-key')
        .mockReturnValueOnce('test@example.com');

      await service.onModuleInit();
    });

    it('should send notification to single device successfully', async () => {
      const token = 'test-device-token';
      const notification = {
        title: 'Test Title',
        body: 'Test Body',
      };
      const data = { type: 'test' };
      const mockResponse = 'message-id-12345';

      mockMessaging.send.mockResolvedValue(mockResponse);

      const result = await service.sendToDevice(token, notification, data);

      expect(mockMessaging.send).toHaveBeenCalledWith({
        token,
        notification: {
          title: 'Test Title',
          body: 'Test Body',
        },
        data,
        android: {
          priority: 'high',
          notification: {
            channelId: 'betty_alarm',
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
      });
      expect(result).toBe(mockResponse);
    });

    it('should handle empty or whitespace image URL', async () => {
      const token = 'test-device-token';
      const notification = {
        title: 'Test Title',
        body: 'Test Body',
        imageUrl: '   ',
      };

      mockMessaging.send.mockResolvedValue('message-id');

      await service.sendToDevice(token, notification);

      const sentMessage = mockMessaging.send.mock.calls[0][0];
      expect(sentMessage.notification).not.toHaveProperty('imageUrl');
    });

    it('should handle Firebase send errors', async () => {
      const token = 'test-device-token';
      const notification = { title: 'Test', body: 'Test' };
      const error = new Error('Firebase send failed');

      mockMessaging.send.mockRejectedValue(error);

      await expect(service.sendToDevice(token, notification)).rejects.toThrow(
        error
      );
    });

    it('should send notification without data parameter', async () => {
      const token = 'test-device-token';
      const notification = { title: 'Test', body: 'Test' };

      mockMessaging.send.mockResolvedValue('message-id');

      await service.sendToDevice(token, notification);

      const sentMessage = mockMessaging.send.mock.calls[0][0];
      expect(sentMessage.data).toEqual({});
    });
  });

  describe('sendToMultipleDevices', () => {
    beforeEach(async () => {
      mockConfigService.get
        .mockReturnValueOnce('test-project-id')
        .mockReturnValueOnce('test-private-key')
        .mockReturnValueOnce('test@example.com');

      await service.onModuleInit();
    });

    it('should send notification to multiple devices successfully', async () => {
      const tokens = ['token1', 'token2', 'token3'];
      const notification = {
        title: 'Test Title',
        body: 'Test Body',
      };
      const data = { type: 'test' };
      const mockResponse = {
        successCount: 3,
        failureCount: 0,
        responses: [],
      };

      mockMessaging.sendEachForMulticast.mockResolvedValue(mockResponse);

      const result = await service.sendToMultipleDevices(
        tokens,
        notification,
        data
      );

      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledWith({
        tokens,
        notification: {
          title: 'Test Title',
          body: 'Test Body',
        },
        data,
        android: {
          priority: 'high',
          notification: {
            channelId: 'betty_alarm',
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
      });
      expect(result).toBe(mockResponse);
    });

    it('should handle partial failures in multicast', async () => {
      const tokens = ['token1', 'token2'];
      const notification = { title: 'Test', body: 'Test' };
      const mockResponse = {
        successCount: 1,
        failureCount: 1,
        responses: [],
      };

      mockMessaging.sendEachForMulticast.mockResolvedValue(mockResponse);

      const result = await service.sendToMultipleDevices(tokens, notification);

      expect(result).toBe(mockResponse);
    });

    it('should handle multicast send errors', async () => {
      const tokens = ['token1', 'token2'];
      const notification = { title: 'Test', body: 'Test' };
      const error = new Error('Multicast send failed');

      mockMessaging.sendEachForMulticast.mockRejectedValue(error);

      await expect(
        service.sendToMultipleDevices(tokens, notification)
      ).rejects.toThrow(error);
    });

    it('should send multicast notification without data parameter', async () => {
      const tokens = ['token1', 'token2'];
      const notification = { title: 'Test', body: 'Test' };
      const mockResponse = {
        successCount: 2,
        failureCount: 0,
        responses: [],
      };

      mockMessaging.sendEachForMulticast.mockResolvedValue(mockResponse);

      await service.sendToMultipleDevices(tokens, notification);

      const sentMessage = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(sentMessage.data).toEqual({});
    });
  });
});
