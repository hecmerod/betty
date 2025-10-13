import {
  TriggerAlarmUseCase,
  AlarmTriggerData,
} from '../trigger-alarm.use-case';
import { AlarmRepository } from '../../../../domain/repositories/alarm.repository';
import { SendNotificationUseCase } from '../../../../../notifications/application/use-cases/send-notification/send-notification.use-case';
import { Alarm } from '../../../../domain/entities/alarm.entity';

describe('TriggerAlarmUseCase', () => {
  let useCase: TriggerAlarmUseCase;
  let mockAlarmRepository: jest.Mocked<AlarmRepository>;
  let mockSendNotificationUseCase: jest.Mocked<SendNotificationUseCase>;

  beforeEach(() => {
    mockAlarmRepository = {
      activate: jest.fn(),
      deactivate: jest.fn(),
      get: jest.fn(),
      save: jest.fn(),
    } as jest.Mocked<AlarmRepository>;

    mockSendNotificationUseCase = {
      execute: jest.fn(),
    } as unknown as jest.Mocked<SendNotificationUseCase>;

    useCase = new TriggerAlarmUseCase(
      mockAlarmRepository,
      mockSendNotificationUseCase
    );
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(useCase).toBeDefined();
  });

  describe('execute', () => {
    it('should send notification when alarm is active', async () => {
      const activeAlarm = new Alarm(true);
      mockAlarmRepository.get.mockResolvedValue(activeAlarm);
      mockSendNotificationUseCase.execute.mockResolvedValue(undefined);

      const result = await useCase.execute();

      expect(mockAlarmRepository.get).toHaveBeenCalledTimes(1);
      expect(mockSendNotificationUseCase.execute).toHaveBeenCalledWith({
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
          eventType: 'detection',
        },
      });
      expect(result).toEqual({ notificationSent: true });
    });

    it('should send notification with custom trigger data', async () => {
      const activeAlarm = new Alarm(true);
      const triggerData: AlarmTriggerData = {
        eventType: 'motion_detected',
        detectionType: 'motion',
        confidence: 0.95,
        metadata: { cameraId: 'cam-01' },
      };

      mockAlarmRepository.get.mockResolvedValue(activeAlarm);
      mockSendNotificationUseCase.execute.mockResolvedValue(undefined);

      const result = await useCase.execute(triggerData);

      expect(mockSendNotificationUseCase.execute).toHaveBeenCalledWith({
        token: '',
        notification: {
          title: '🚨 BETTY ALARM',
          body: 'Persona detectada en tu hogar',
          imageUrl: '',
        },
        data: {
          type: 'alarm',
          timestamp: expect.any(String),
          detectionType: 'motion',
          eventType: 'motion_detected',
        },
      });
      expect(result).toEqual({ notificationSent: true });
    });

    it('should not send notification when alarm is inactive', async () => {
      const inactiveAlarm = new Alarm(false);
      mockAlarmRepository.get.mockResolvedValue(inactiveAlarm);

      const result = await useCase.execute();

      expect(mockAlarmRepository.get).toHaveBeenCalledTimes(1);
      expect(mockSendNotificationUseCase.execute).not.toHaveBeenCalled();
      expect(result).toBeUndefined();
    });

    it('should return notificationSent false when notification fails', async () => {
      const activeAlarm = new Alarm(true);
      mockAlarmRepository.get.mockResolvedValue(activeAlarm);
      mockSendNotificationUseCase.execute.mockRejectedValue(
        new Error('Notification failed')
      );

      const result = await useCase.execute();

      expect(mockAlarmRepository.get).toHaveBeenCalledTimes(1);
      expect(mockSendNotificationUseCase.execute).toHaveBeenCalledTimes(1);
      expect(result).toEqual({ notificationSent: false });
    });

    it('should handle notification errors gracefully', async () => {
      const activeAlarm = new Alarm(true);
      mockAlarmRepository.get.mockResolvedValue(activeAlarm);
      mockSendNotificationUseCase.execute.mockRejectedValue('Network error');

      const result = await useCase.execute();

      expect(result).toEqual({ notificationSent: false });
    });
  });
});
