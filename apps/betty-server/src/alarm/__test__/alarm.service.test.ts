import { AlarmService } from '../alarm.service';
import { NotificationsService } from '../../notifications/notifications.service';

describe('AlarmService', () => {
  let service: AlarmService;
  let mockNotificationsService: jest.Mocked<NotificationsService>;

  beforeEach(() => {
    mockNotificationsService = {
      notifyAllDevices: jest.fn(),
    } as unknown as jest.Mocked<NotificationsService>;

    service = new AlarmService(mockNotificationsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('activate', () => {
    it('should activate alarm and return success response', () => {
      expect(service._isActive).toBe(false);

      const result = service.activate();

      expect(result).toEqual({
        success: true,
        message: 'Alarm has been activated',
        status: 'active',
      });
      expect(service._isActive).toBe(true);
    });
  });

  describe('deactivate', () => {
    it('should deactivate alarm and return success response', () => {
      service.activate();

      expect(service._isActive).toBe(true);

      const result = service.deactivate();

      expect(result).toEqual({
        success: true,
        message: 'Alarm has been deactivated',
        status: 'inactive',
      });
      expect(service._isActive).toBe(false);
    });
  });

  describe('getStatus', () => {
    it('should return correct status when alarm is inactive', () => {
      const result = service.getStatus();

      expect(result).toHaveProperty('active', false);
      expect(result).toHaveProperty('status', 'inactive');
      expect(result).toHaveProperty('timestamp');
      expect(result.timestamp).toMatch(
        /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/
      );
    });

    it('should return correct status when alarm is active', () => {
      service.activate();
      const result = service.getStatus();

      expect(result).toHaveProperty('active', true);
      expect(result).toHaveProperty('status', 'active');
      expect(result).toHaveProperty('timestamp');
    });

    it('should return valid timestamp in ISO format', () => {
      const result = service.getStatus();

      expect(new Date(result.timestamp).getTime()).toBeGreaterThan(0);
    });
  });

  describe('trigger', () => {
    it('should send notification when alarm is active', async () => {
      const mockData = { event_type: 'person' };
      mockNotificationsService.notifyAllDevices.mockResolvedValue({
        success: true,
      });

      service.activate();
      expect(service._isActive).toBe(true);

      await service.trigger(mockData);

      expect(mockNotificationsService.notifyAllDevices).toHaveBeenCalledWith({
        token: '',
        notification: {
          title: '🚨 BETTY ALARM',
          body: 'Persona detectada en tu hogar',
          imageUrl: '',
        },
        data: {
          type: 'alarm',
          timestamp: expect.any(String),
          detectionType: 'person',
        },
      });
    });

    it('should not send notification when alarm is inactive', async () => {
      const mockData = { event_type: 'person' };

      expect(service._isActive).toBe(false);

      await service.trigger(mockData);

      expect(mockNotificationsService.notifyAllDevices).not.toHaveBeenCalled();
    });

    it('should use default detection type when event_type is not provided', async () => {
      const mockData = {};
      mockNotificationsService.notifyAllDevices.mockResolvedValue({
        success: true,
      });

      service.activate();
      await service.trigger(mockData);

      expect(mockNotificationsService.notifyAllDevices).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            detectionType: 'person',
          }),
        })
      );
    });

    it('should handle notification service errors gracefully', async () => {
      const mockData = { event_type: 'person' };
      const error = new Error('Firebase error');

      mockNotificationsService.notifyAllDevices.mockRejectedValue(error);

      service.activate();

      await expect(service.trigger(mockData)).rejects.toThrow(error);
    });

    it('should generate valid timestamp in trigger data', async () => {
      const mockData = { event_type: 'person' };
      mockNotificationsService.notifyAllDevices.mockResolvedValue({
        success: true,
      });

      service.activate();
      await service.trigger(mockData);

      const callArgs =
        mockNotificationsService.notifyAllDevices.mock.calls[0][0];
      expect(callArgs.data.timestamp).toMatch(
        /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/
      );
      expect(new Date(callArgs.data.timestamp).getTime()).toBeGreaterThan(0);
    });
  });
});
