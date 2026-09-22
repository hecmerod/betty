import {
  TriggerAlarmUseCase,
  AlarmTriggerDataInput,
} from '../trigger-alarm.use-case';
import { AlarmRepository } from '../../../../domain/repositories/alarm.repository';
import { SendNotificationUseCase } from '../../../../../notifications/application/use-cases/send-notification/send-notification.use-case';
import { Alarm } from '../../../../domain/entities/alarm.entity';
import { AlarmService } from '../../../services/alarm.service';

describe('TriggerAlarmUseCase', () => {
  let useCase: TriggerAlarmUseCase;
  let mockAlarmRepository: jest.Mocked<AlarmRepository>;
  let mockSendNotificationUseCase: jest.Mocked<
    Pick<SendNotificationUseCase, 'execute'>
  >;
  let mockAlarmService: jest.Mocked<Pick<AlarmService, 'activate'>>;

  beforeEach(() => {
    mockAlarmRepository = {
      activate: jest.fn(),
      deactivate: jest.fn(),
      get: jest.fn(),
    } as jest.Mocked<AlarmRepository>;

    mockSendNotificationUseCase = {
      execute: jest.fn(),
    };

    mockAlarmService = {
      activate: jest.fn(),
    };

    useCase = new TriggerAlarmUseCase(
      mockAlarmRepository,
      mockSendNotificationUseCase as unknown as SendNotificationUseCase,
      mockAlarmService as unknown as AlarmService
    );
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(useCase).toBeDefined();
  });

  describe('execute', () => {
    it('should send a notification and activate the alarm service when the alarm is active', async () => {
      mockAlarmRepository.get.mockResolvedValue(new Alarm(true));
      mockSendNotificationUseCase.execute.mockResolvedValue(undefined);

      const result = await useCase.execute();

      expect(mockAlarmRepository.get).toHaveBeenCalledTimes(1);
      expect(mockSendNotificationUseCase.execute).toHaveBeenCalledWith({
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
      expect(mockAlarmService.activate).toHaveBeenCalledTimes(1);
      expect(result).toBe(true);
    });

    it('should send a notification with custom trigger data', async () => {
      const triggerData: AlarmTriggerDataInput = {
        eventType: 'motion_detected',
        detectionType: 'motion',
        confidence: 0.95,
        metadata: { cameraId: 'cam-01' },
      };

      mockAlarmRepository.get.mockResolvedValue(new Alarm(true));
      mockSendNotificationUseCase.execute.mockResolvedValue(undefined);

      const result = await useCase.execute(triggerData);

      expect(mockSendNotificationUseCase.execute).toHaveBeenCalledWith({
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
      expect(mockAlarmService.activate).toHaveBeenCalledTimes(1);
      expect(result).toBe(true);
    });

    it('should not notify or activate the service when the alarm is inactive', async () => {
      mockAlarmRepository.get.mockResolvedValue(new Alarm(false));

      const result = await useCase.execute();

      expect(mockAlarmRepository.get).toHaveBeenCalledTimes(1);
      expect(mockSendNotificationUseCase.execute).not.toHaveBeenCalled();
      expect(mockAlarmService.activate).not.toHaveBeenCalled();
      expect(result).toBe(false);
    });

    it('should not activate the service when the notification fails', async () => {
      mockAlarmRepository.get.mockResolvedValue(new Alarm(true));
      mockSendNotificationUseCase.execute.mockRejectedValue(
        new Error('Notification failed')
      );

      const result = await useCase.execute();

      expect(mockSendNotificationUseCase.execute).toHaveBeenCalledTimes(1);
      expect(mockAlarmService.activate).not.toHaveBeenCalled();
      expect(result).toBe(false);
    });

    it('should handle non-Error notification failures', async () => {
      mockAlarmRepository.get.mockResolvedValue(new Alarm(true));
      mockSendNotificationUseCase.execute.mockRejectedValue('Network error');

      const result = await useCase.execute();

      expect(mockAlarmService.activate).not.toHaveBeenCalled();
      expect(result).toBe(false);
    });
  });
});
