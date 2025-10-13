import { NotificationsController } from '../notifications.controller';
import { RegisterTokenUseCase } from '../../../application/use-cases/register-token/register-token.use-case';
import { SendNotificationUseCase } from '../../../application/use-cases/send-notification/send-notification.use-case';
import {
  SendNotificationDto,
  RegisterTokenDto,
} from '../../../presentation/dto/notification.dto';
import { HttpException, HttpStatus } from '@nestjs/common';

describe('NotificationsController', () => {
  let controller: NotificationsController;
  let mockRegisterTokenUseCase: jest.Mocked<RegisterTokenUseCase>;
  let mockSendNotificationUseCase: jest.Mocked<SendNotificationUseCase>;

  beforeEach(() => {
    mockRegisterTokenUseCase = {
      execute: jest.fn(),
    } as unknown as jest.Mocked<RegisterTokenUseCase>;

    mockSendNotificationUseCase = {
      execute: jest.fn(),
    } as unknown as jest.Mocked<SendNotificationUseCase>;

    controller = new NotificationsController(
      mockRegisterTokenUseCase,
      mockSendNotificationUseCase
    );
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('registerToken', () => {
    it('should register token successfully', async () => {
      const registerTokenDto: RegisterTokenDto = {
        token: 'test-token',
        userId: 'user-123',
        platform: 'android',
      };
      const mockResponse = {
        success: true,
        message: 'Token registered successfully',
      };
      mockRegisterTokenUseCase.execute.mockResolvedValue(mockResponse);

      const result = await controller.registerToken(registerTokenDto);

      expect(mockRegisterTokenUseCase.execute).toHaveBeenCalledWith(
        registerTokenDto
      );
      expect(result).toBe(mockResponse);
    });

    it('should call register token use case execute once', async () => {
      const registerTokenDto: RegisterTokenDto = {
        token: 'test-token',
        userId: 'user-123',
      };

      mockRegisterTokenUseCase.execute.mockResolvedValue({
        success: true,
        message: 'Token registered',
      });

      await controller.registerToken(registerTokenDto);

      expect(mockRegisterTokenUseCase.execute).toHaveBeenCalledTimes(1);
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
        tokensUsed: 2,
      };
      mockSendNotificationUseCase.execute.mockResolvedValue(mockResponse);

      const result = await controller.sendNotification(sendNotificationDto);

      expect(mockSendNotificationUseCase.execute).toHaveBeenCalledWith(
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
      mockSendNotificationUseCase.execute.mockRejectedValue(
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
      mockSendNotificationUseCase.execute.mockRejectedValue(
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

    it('should call send notification use case execute once', async () => {
      const sendNotificationDto: SendNotificationDto = {
        token: 'test-token',
        notification: {
          title: 'Test Title',
          body: 'Test Body',
        },
      };
      mockSendNotificationUseCase.execute.mockResolvedValue({
        success: true,
        tokensUsed: 1,
      });

      await controller.sendNotification(sendNotificationDto);

      expect(mockSendNotificationUseCase.execute).toHaveBeenCalledTimes(1);
    });
  });
});
