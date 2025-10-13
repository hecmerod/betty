import { AlarmController } from '../alarm.controller';
import { ActivateAlarmUseCase } from '../../../application/use-cases/activate-alarm/activate-alarm.use-case';
import { DeactivateAlarmUseCase } from '../../../application/use-cases/deactivate-alarm/deactivate-alarm.use-case';
import {
  TriggerAlarmUseCase,
  AlarmTriggerData,
} from '../../../application/use-cases/trigger-alarm/trigger-alarm.use-case';
import { GetAlarmStatusUseCase } from '../../../application/use-cases/get-alarm-status/get-alarm-status.use-case';

describe('AlarmController', () => {
  let controller: AlarmController;
  let mockActivateAlarmUseCase: jest.Mocked<ActivateAlarmUseCase>;
  let mockDeactivateAlarmUseCase: jest.Mocked<DeactivateAlarmUseCase>;
  let mockTriggerAlarmUseCase: jest.Mocked<TriggerAlarmUseCase>;
  let mockGetAlarmStatusUseCase: jest.Mocked<GetAlarmStatusUseCase>;

  beforeEach(() => {
    mockActivateAlarmUseCase = {
      execute: jest.fn(),
    } as unknown as jest.Mocked<ActivateAlarmUseCase>;

    mockDeactivateAlarmUseCase = {
      execute: jest.fn(),
    } as unknown as jest.Mocked<DeactivateAlarmUseCase>;

    mockTriggerAlarmUseCase = {
      execute: jest.fn(),
    } as unknown as jest.Mocked<TriggerAlarmUseCase>;

    mockGetAlarmStatusUseCase = {
      execute: jest.fn(),
    } as unknown as jest.Mocked<GetAlarmStatusUseCase>;

    controller = new AlarmController(
      mockActivateAlarmUseCase,
      mockDeactivateAlarmUseCase,
      mockTriggerAlarmUseCase,
      mockGetAlarmStatusUseCase
    );
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getAlarmStatus', () => {
    it('should return alarm status', async () => {
      const expectedStatus = {
        active: false,
        status: 'inactive',
        timestamp: '2024-01-01T00:00:00.000Z',
        activeDuration: 0,
      };

      mockGetAlarmStatusUseCase.execute.mockResolvedValue(expectedStatus);

      const result = await controller.getAlarmStatus();

      expect(mockGetAlarmStatusUseCase.execute).toHaveBeenCalledTimes(1);
      expect(result).toEqual(expectedStatus);
    });

    it('should return alarm status with timestamps', async () => {
      const expectedStatus = {
        active: true,
        status: 'active',
        timestamp: '2024-01-01T00:00:00.000Z',
        lastActivatedAt: '2024-01-01T00:00:00.000Z',
        lastDeactivatedAt: undefined,
        lastTriggeredAt: undefined,
        activeDuration: 1000,
      };

      mockGetAlarmStatusUseCase.execute.mockResolvedValue(expectedStatus);

      const result = await controller.getAlarmStatus();

      expect(result).toEqual(expectedStatus);
    });
  });

  describe('activateAlarm', () => {
    it('should activate the alarm successfully', async () => {
      const expectedResponse = {
        success: true,
        message: 'Alarm has been activated',
        status: 'active',
        timestamp: '2024-01-01T00:00:00.000Z',
      };

      mockActivateAlarmUseCase.execute.mockResolvedValue(expectedResponse);

      const result = await controller.activateAlarm();

      expect(mockActivateAlarmUseCase.execute).toHaveBeenCalledTimes(1);
      expect(result).toEqual(expectedResponse);
    });

    it('should return error when activation fails', async () => {
      const expectedResponse = {
        success: false,
        message: 'Alarm is already active',
        timestamp: '2024-01-01T00:00:00.000Z',
      };

      mockActivateAlarmUseCase.execute.mockResolvedValue(expectedResponse);

      const result = await controller.activateAlarm();

      expect(result).toEqual(expectedResponse);
      expect(result.success).toBe(false);
    });
  });

  describe('deactivateAlarm', () => {
    it('should deactivate the alarm successfully', async () => {
      const expectedResponse = {
        success: true,
        message: 'Alarm has been deactivated',
        status: 'inactive',
        timestamp: '2024-01-01T00:00:00.000Z',
      };

      mockDeactivateAlarmUseCase.execute.mockResolvedValue(expectedResponse);

      const result = await controller.deactivateAlarm();

      expect(mockDeactivateAlarmUseCase.execute).toHaveBeenCalledTimes(1);
      expect(result).toEqual(expectedResponse);
    });

    it('should return error when deactivation fails', async () => {
      const expectedResponse = {
        success: false,
        message: 'Alarm is already inactive',
        timestamp: '2024-01-01T00:00:00.000Z',
      };

      mockDeactivateAlarmUseCase.execute.mockResolvedValue(expectedResponse);

      const result = await controller.deactivateAlarm();

      expect(result).toEqual(expectedResponse);
      expect(result.success).toBe(false);
    });
  });

  describe('triggerAlarm', () => {
    it('should trigger alarm without body', async () => {
      const expectedResponse = {
        notificationSent: true,
      };

      mockTriggerAlarmUseCase.execute.mockResolvedValue(expectedResponse);

      const result = await controller.triggerAlarm({});

      expect(mockTriggerAlarmUseCase.execute).toHaveBeenCalledWith({});
      expect(result).toEqual(expectedResponse);
    });

    it('should trigger alarm with trigger data', async () => {
      const triggerData: AlarmTriggerData = {
        eventType: 'motion_detected',
        detectionType: 'person',
        confidence: 0.95,
        metadata: { cameraId: 'cam-01' },
      };

      const expectedResponse = {
        notificationSent: true,
      };

      mockTriggerAlarmUseCase.execute.mockResolvedValue(expectedResponse);

      const result = await controller.triggerAlarm(triggerData);

      expect(mockTriggerAlarmUseCase.execute).toHaveBeenCalledWith(triggerData);
      expect(result).toEqual(expectedResponse);
    });

    it('should return notificationSent false when notification fails', async () => {
      const expectedResponse = {
        notificationSent: false,
      };

      mockTriggerAlarmUseCase.execute.mockResolvedValue(expectedResponse);

      const result = await controller.triggerAlarm({});

      expect(result).toEqual(expectedResponse);
      expect(result.notificationSent).toBe(false);
    });

    it('should handle undefined response from trigger use case', async () => {
      mockTriggerAlarmUseCase.execute.mockResolvedValue(undefined);

      const result = await controller.triggerAlarm({});

      expect(result).toBeUndefined();
    });
  });
});
