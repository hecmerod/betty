import { NotificationsController } from '../notifications.controller';
import { NotificationsService } from '../notifications.service';
import { SendNotificationDto, RegisterTokenDto } from '../dto/notification.dto';
import { HttpException, HttpStatus } from '@nestjs/common';

describe('NotificationsController', () => {
  let controller: NotificationsController;
  let mockNotificationsService: jest.Mocked<NotificationsService>;

  beforeEach(() => {
    mockNotificationsService = {
      registerToken: jest.fn(),
      sendNotification: jest.fn(),
    } as unknown as jest.Mocked<NotificationsService>;

    controller = new NotificationsController(mockNotificationsService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('registerToken', () => {
    it('should register token successfully', () => {
      const registerTokenDto: RegisterTokenDto = {
        token: 'test-token',
        userId: 'user-123',
        platform: 'android',
      };
      const mockResponse = {
        success: true,
        message: 'Token registered successfully',
      };
      mockNotificationsService.registerToken.mockReturnValue(mockResponse);

      const result = controller.registerToken(registerTokenDto);

      expect(mockNotificationsService.registerToken).toHaveBeenCalledWith(
        registerTokenDto
      );
      expect(result).toBe(mockResponse);
    });

    it('should call notifications service registerToken once', () => {
      const registerTokenDto: RegisterTokenDto = {
        token: 'test-token',
        userId: 'user-123',
      };

      controller.registerToken(registerTokenDto);

      expect(mockNotificationsService.registerToken).toHaveBeenCalledTimes(1);
    });
  });

  describe('sendNotification', () => {
    it('should send notification successfully', async () => {
      const sendNotificationDto: SendNotificationDto = {
        token: 'test-token',
        notification: {
          title: 'Test Title',
          body: 'Test Body',
        },
        data: {
          type: 'test',
          timestamp: new Date().toISOString(),
        },
      };
      const mockResponse = {
        success: true,
        messageId: 'msg-123',
      };
      mockNotificationsService.notifyAllDevices.mockResolvedValue(mockResponse);

      const result = await controller.sendNotification(sendNotificationDto);

      expect(mockNotificationsService.notifyAllDevices).toHaveBeenCalledWith(
        sendNotificationDto
      );
      expect(result).toBe(mockResponse);
    });

    it('should handle notification service error', async () => {
      const sendNotificationDto: SendNotificationDto = {
        token: 'test-token',
        notification: {
          title: 'Test Title',
          body: 'Test Body',
        },
      };
      mockNotificationsService.notifyAllDevices.mockRejectedValue(
        new Error('Service error')
      );

      await expect(
        controller.sendNotification(sendNotificationDto)
      ).rejects.toThrow(HttpException);
      await expect(
        controller.sendNotification(sendNotificationDto)
      ).rejects.toThrow('Error enviando notificación');
    });

    it('should throw HttpException with correct status on error', async () => {
      const sendNotificationDto: SendNotificationDto = {
        token: 'test-token',
        notification: {
          title: 'Test Title',
          body: 'Test Body',
        },
      };
      mockNotificationsService.notifyAllDevices.mockRejectedValue(
        new Error('Service error')
      );

      try {
        await controller.sendNotification(sendNotificationDto);
      } catch (error) {
        expect(error).toBeInstanceOf(HttpException);
        expect((error as HttpException).getStatus()).toBe(
          HttpStatus.INTERNAL_SERVER_ERROR
        );
      }
    });

    it('should call notifications service sendNotification once', async () => {
      const sendNotificationDto: SendNotificationDto = {
        token: 'test-token',
        notification: {
          title: 'Test Title',
          body: 'Test Body',
        },
      };
      mockNotificationsService.notifyAllDevices.mockResolvedValue({
        success: true,
      });

      await controller.sendNotification(sendNotificationDto);

      expect(mockNotificationsService.notifyAllDevices).toHaveBeenCalledTimes(
        1
      );
    });
  });
});
