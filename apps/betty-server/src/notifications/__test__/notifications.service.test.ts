import { NotificationsTestingService } from './notifications-testing.service';
import { FirebaseService } from '../firebase.service';
import { RegisterTokenDto, SendNotificationDto } from '../dto/notification.dto';

describe('NotificationsService', () => {
  let service: NotificationsTestingService;
  let mockFirebaseService: jest.Mocked<FirebaseService>;

  beforeEach(() => {
    mockFirebaseService = {
      sendToMultipleDevices: jest.fn(),
    } as unknown as jest.Mocked<FirebaseService>;

    service = new NotificationsTestingService(mockFirebaseService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('registerToken', () => {
    it('should register token successfully', () => {
      const registerTokenDto: RegisterTokenDto = {
        token: 'test-firebase-token-12345',
      };

      const result = service.registerToken(registerTokenDto);

      expect(result).toEqual({
        success: true,
        message: 'Token registrado correctamente',
      });
      expect(service._deviceTokens.has('test-firebase-token-12345')).toBe(true);
    });

    it('should store multiple tokens', () => {
      const token1: RegisterTokenDto = {
        token: 'token-1',
      };
      const token2: RegisterTokenDto = {
        token: 'token-2',
      };

      const result1 = service.registerToken(token1);
      const result2 = service.registerToken(token2);

      expect(result1.success).toBe(true);
      expect(result2.success).toBe(true);
      expect(service._deviceTokens.size).toBe(2);
      expect(service._deviceTokens.has('token-1')).toBe(true);
      expect(service._deviceTokens.has('token-2')).toBe(true);
    });

    it('should overwrite existing token with same token string', () => {
      const originalToken: RegisterTokenDto = {
        token: 'same-token',
      };
      const updatedToken: RegisterTokenDto = {
        token: 'same-token',
      };

      service.registerToken(originalToken);
      const result = service.registerToken(updatedToken);

      expect(result.success).toBe(true);
      expect(service._deviceTokens.size).toBe(1);
    });
  });

  describe('notifyAllDevices', () => {
    it('should send notification to all registered devices', async () => {
      const registerTokenDto: RegisterTokenDto = {
        token: 'test-firebase-token-12345',
      };
      service.registerToken(registerTokenDto);

      const sendNotificationDto: SendNotificationDto = {
        token: '',
        notification: {
          title: 'Test Notification',
          body: 'This is a test notification',
        },
        data: {
          type: 'test',
          timestamp: new Date().toISOString(),
        },
      };

      mockFirebaseService.sendToMultipleDevices.mockResolvedValue(undefined);

      const result = await service.notifyAllDevices(sendNotificationDto);

      expect(service._deviceTokens.size).toBe(1);
      expect(mockFirebaseService.sendToMultipleDevices).toHaveBeenCalledWith(
        ['test-firebase-token-12345'],
        sendNotificationDto.notification,
        sendNotificationDto.data
      );
      expect(result).toEqual({ success: true });
    });

    it('should send notification to multiple registered devices', async () => {
      const token1: RegisterTokenDto = {
        token: 'token-1',
      };
      const token2: RegisterTokenDto = {
        token: 'token-2',
      };
      service.registerToken(token1);
      service.registerToken(token2);

      const sendNotificationDto: SendNotificationDto = {
        token: '',
        notification: {
          title: 'Test Notification',
          body: 'This is a test notification',
        },
      };

      mockFirebaseService.sendToMultipleDevices.mockResolvedValue(undefined);

      const result = await service.notifyAllDevices(sendNotificationDto);

      expect(service._deviceTokens.size).toBe(2);
      expect(mockFirebaseService.sendToMultipleDevices).toHaveBeenCalledTimes(
        1
      );
      expect(mockFirebaseService.sendToMultipleDevices).toHaveBeenCalledWith(
        ['token-1', 'token-2'],
        sendNotificationDto.notification,
        sendNotificationDto.data
      );
      expect(result).toEqual({ success: true });
    });

    it('should return success even when no devices are registered', async () => {
      const sendNotificationDto: SendNotificationDto = {
        token: '',
        notification: {
          title: 'Test Notification',
          body: 'This is a test notification',
        },
      };

      const result = await service.notifyAllDevices(sendNotificationDto);

      expect(service._deviceTokens.size).toBe(0);
      expect(mockFirebaseService.sendToMultipleDevices).not.toHaveBeenCalled();
      expect(result).toEqual({ success: true });
    });
  });
});
