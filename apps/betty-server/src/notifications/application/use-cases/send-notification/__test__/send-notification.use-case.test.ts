import { SendNotificationUseCase } from '../send-notification.use-case';
import { FirebaseService } from '../../../../infrastructure/adapters/firebase.service';
import { DeviceTokenRepository } from '../../../../domain/repositories/device-token.repository';
import {
  SendNotificationDto,
  NotificationDto,
} from '../../../../presentation/dto/notification.dto';

describe('SendNotificationUseCase', () => {
  let useCase: SendNotificationUseCase;
  let mockFirebaseService: jest.Mocked<FirebaseService>;
  let mockDeviceTokenRepository: jest.Mocked<DeviceTokenRepository>;

  beforeEach(() => {
    mockFirebaseService = {
      sendToMultipleDevices: jest.fn(),
    } as unknown as jest.Mocked<FirebaseService>;

    mockDeviceTokenRepository = {
      getAll: jest.fn(),
      save: jest.fn(),
    };

    useCase = new SendNotificationUseCase(
      mockFirebaseService,
      mockDeviceTokenRepository
    );
  });

  it('should be defined', () => {
    expect(useCase).toBeDefined();
  });

  describe('execute', () => {
    it('should send notification successfully when tokens are available', async () => {
      const notificationDto: NotificationDto = {
        title: 'Test Notification',
        body: 'This is a test notification',
      };

      const sendNotificationDto: SendNotificationDto = {
        token: 'test-token',
        notification: notificationDto,
        data: { key: 'value' },
      };

      const tokens = ['token1', 'token2'];
      mockDeviceTokenRepository.getAll.mockResolvedValue(tokens);
      mockFirebaseService.sendToMultipleDevices.mockResolvedValue({
        responses: [],
        successCount: 2,
        failureCount: 0,
      });

      const result = await useCase.execute(sendNotificationDto);

      expect(result).toEqual({
        success: true,
        tokensUsed: 2,
      });
      expect(mockDeviceTokenRepository.getAll).toHaveBeenCalled();
      expect(mockFirebaseService.sendToMultipleDevices).toHaveBeenCalledWith(
        tokens,
        notificationDto,
        { key: 'value' }
      );
    });

    it('should return success with 0 tokens when no tokens are available', async () => {
      const notificationDto: NotificationDto = {
        title: 'Test Notification',
        body: 'This is a test notification',
      };

      const sendNotificationDto: SendNotificationDto = {
        token: 'test-token',
        notification: notificationDto,
      };

      mockDeviceTokenRepository.getAll.mockResolvedValue([]);

      const result = await useCase.execute(sendNotificationDto);

      expect(result).toEqual({
        success: true,
        tokensUsed: 0,
      });
      expect(mockDeviceTokenRepository.getAll).toHaveBeenCalled();
      expect(mockFirebaseService.sendToMultipleDevices).not.toHaveBeenCalled();
    });

    it('should send notification without data parameter', async () => {
      const notificationDto: NotificationDto = {
        title: 'Test Notification',
        body: 'This is a test notification',
      };

      const sendNotificationDto: SendNotificationDto = {
        token: 'test-token',
        notification: notificationDto,
      };

      const tokens = ['token1'];
      mockDeviceTokenRepository.getAll.mockResolvedValue(tokens);
      mockFirebaseService.sendToMultipleDevices.mockResolvedValue({
        responses: [],
        successCount: 1,
        failureCount: 0,
      });

      const result = await useCase.execute(sendNotificationDto);

      expect(result).toEqual({
        success: true,
        tokensUsed: 1,
      });
      expect(mockFirebaseService.sendToMultipleDevices).toHaveBeenCalledWith(
        tokens,
        notificationDto,
        undefined
      );
    });

    it('should send notification with multiple tokens', async () => {
      const notificationDto: NotificationDto = {
        title: 'Test Notification',
        body: 'This is a test notification',
      };

      const sendNotificationDto: SendNotificationDto = {
        token: 'test-token',
        notification: notificationDto,
        data: { type: 'alarm', priority: 'high' },
      };

      const tokens = ['token1', 'token2', 'token3'];
      mockDeviceTokenRepository.getAll.mockResolvedValue(tokens);
      mockFirebaseService.sendToMultipleDevices.mockResolvedValue({
        responses: [],
        successCount: 3,
        failureCount: 0,
      });

      const result = await useCase.execute(sendNotificationDto);

      expect(result).toEqual({
        success: true,
        tokensUsed: 3,
      });
      expect(mockFirebaseService.sendToMultipleDevices).toHaveBeenCalledWith(
        tokens,
        notificationDto,
        { type: 'alarm', priority: 'high' }
      );
    });
  });
});
