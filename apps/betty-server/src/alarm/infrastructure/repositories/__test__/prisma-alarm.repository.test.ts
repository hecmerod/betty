import { PrismaAlarmRepository } from '../prisma-alarm.repository';
import { PrismaService } from '../../../../shared/prisma/prisma.service';
import { Alarm } from '../../../domain/entities/alarm.entity';

describe('PrismaAlarmRepository', () => {
  let repository: PrismaAlarmRepository;
  let mockPrismaService: jest.Mocked<PrismaService>;

  const mockPrismaAlarm = {
    findUnique: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
  };

  beforeEach(() => {
    mockPrismaService = {
      alarm: mockPrismaAlarm,
    } as unknown as jest.Mocked<PrismaService>;

    repository = new PrismaAlarmRepository(mockPrismaService);

    // Reset mocks
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(repository).toBeDefined();
  });

  describe('onModuleInit', () => {
    it('should create alarm record if it does not exist', async () => {
      mockPrismaAlarm.findUnique.mockResolvedValue(null);
      mockPrismaAlarm.create.mockResolvedValue({
        id: 1,
        isActive: false,
        password: '1234',
        createdAt: new Date(),
        lastActivatedAt: null,
        lastDeactivatedAt: null,
        lastTriggeredAt: null,
      });

      await repository.onModuleInit();

      expect(mockPrismaAlarm.findUnique).toHaveBeenCalledWith({
        where: { id: 1 },
      });
      expect(mockPrismaAlarm.create).toHaveBeenCalledWith({
        data: {
          id: 1,
          isActive: false,
        },
      });
    });

    it('should not create alarm record if it already exists', async () => {
      mockPrismaAlarm.findUnique.mockResolvedValue({
        id: 1,
        isActive: false,
        password: '1234',
        createdAt: new Date(),
        lastActivatedAt: null,
        lastDeactivatedAt: null,
        lastTriggeredAt: null,
      });

      await repository.onModuleInit();

      expect(mockPrismaAlarm.findUnique).toHaveBeenCalledWith({
        where: { id: 1 },
      });
      expect(mockPrismaAlarm.create).not.toHaveBeenCalled();
    });
  });

  describe('activate', () => {
    it('should activate the alarm', async () => {
      const currentDate = new Date();
      mockPrismaAlarm.findUnique.mockResolvedValue({
        id: 1,
        isActive: false,
        password: '1234',
        createdAt: new Date(),
        lastActivatedAt: null,
        lastDeactivatedAt: null,
        lastTriggeredAt: null,
      });
      mockPrismaAlarm.update.mockResolvedValue({
        id: 1,
        isActive: true,
        password: '1234',
        createdAt: new Date(),
        lastActivatedAt: currentDate,
        lastDeactivatedAt: null,
        lastTriggeredAt: null,
      });

      await repository.activate();

      expect(mockPrismaAlarm.findUnique).toHaveBeenCalledWith({
        where: { id: 1 },
      });
      expect(mockPrismaAlarm.update).toHaveBeenCalledWith({
        where: { id: 1 },
        data: {
          isActive: true,
          lastActivatedAt: expect.any(Date),
        },
      });
    });

    it('should throw error when activating already active alarm', async () => {
      mockPrismaAlarm.findUnique.mockResolvedValue({
        id: 1,
        isActive: true,
        password: '1234',
        createdAt: new Date(),
        lastActivatedAt: new Date(),
        lastDeactivatedAt: null,
        lastTriggeredAt: null,
      });

      await expect(repository.activate()).rejects.toThrow(
        'Alarm is already active'
      );

      expect(mockPrismaAlarm.update).not.toHaveBeenCalled();
    });
  });

  describe('deactivate', () => {
    it('should deactivate the alarm', async () => {
      const currentDate = new Date();
      mockPrismaAlarm.findUnique.mockResolvedValue({
        id: 1,
        isActive: true,
        password: '1234',
        createdAt: new Date(),
        lastActivatedAt: new Date(),
        lastDeactivatedAt: null,
        lastTriggeredAt: null,
      });
      mockPrismaAlarm.update.mockResolvedValue({
        id: 1,
        isActive: false,
        password: '1234',
        createdAt: new Date(),
        lastActivatedAt: new Date(),
        lastDeactivatedAt: currentDate,
        lastTriggeredAt: null,
      });

      await repository.deactivate();

      expect(mockPrismaAlarm.findUnique).toHaveBeenCalledWith({
        where: { id: 1 },
      });
      expect(mockPrismaAlarm.update).toHaveBeenCalledWith({
        where: { id: 1 },
        data: {
          isActive: false,
          lastDeactivatedAt: expect.any(Date),
        },
      });
    });

    it('should throw error when deactivating inactive alarm', async () => {
      mockPrismaAlarm.findUnique.mockResolvedValue({
        id: 1,
        isActive: false,
        password: '1234',
        createdAt: new Date(),
        lastActivatedAt: null,
        lastDeactivatedAt: null,
        lastTriggeredAt: null,
      });

      await expect(repository.deactivate()).rejects.toThrow(
        'Alarm is already inactive'
      );

      expect(mockPrismaAlarm.update).not.toHaveBeenCalled();
    });
  });

  describe('get', () => {
    it('should return an Alarm entity with all fields', async () => {
      const createdAt = new Date('2023-01-01T10:00:00Z');
      const lastActivatedAt = new Date('2023-01-02T10:00:00Z');
      const lastDeactivatedAt = new Date('2023-01-03T10:00:00Z');
      const lastTriggeredAt = new Date('2023-01-04T10:00:00Z');

      mockPrismaAlarm.findUnique.mockResolvedValue({
        id: 1,
        isActive: true,
        password: '1234',
        createdAt,
        lastActivatedAt,
        lastDeactivatedAt,
        lastTriggeredAt,
      });

      const alarm = await repository.get();

      expect(alarm).toBeInstanceOf(Alarm);
      expect(alarm.isActive).toBe(true);
      expect(alarm.password).toBe('1234');
      expect(alarm.createdAt).toBe(createdAt);
      expect(alarm.lastActivatedAt).toBe(lastActivatedAt);
      expect(alarm.lastDeactivatedAt).toBe(lastDeactivatedAt);
      expect(alarm.lastTriggeredAt).toBe(lastTriggeredAt);
    });

    it('should return an Alarm entity with null optional fields', async () => {
      const createdAt = new Date('2023-01-01T10:00:00Z');

      mockPrismaAlarm.findUnique.mockResolvedValue({
        id: 1,
        isActive: false,
        password: '1234',
        createdAt,
        lastActivatedAt: null,
        lastDeactivatedAt: null,
        lastTriggeredAt: null,
      });

      const alarm = await repository.get();

      expect(alarm).toBeInstanceOf(Alarm);
      expect(alarm.isActive).toBe(false);
      expect(alarm.createdAt).toBe(createdAt);
      expect(alarm.lastActivatedAt).toBeUndefined();
      expect(alarm.lastDeactivatedAt).toBeUndefined();
      expect(alarm.lastTriggeredAt).toBeUndefined();
    });

    it('should throw error when alarm record is not found', async () => {
      mockPrismaAlarm.findUnique.mockResolvedValue(null);

      await expect(repository.get()).rejects.toThrow('Alarm record not found');
    });
  });

  describe('setPassword', () => {
    it('should update the alarm password', async () => {
      mockPrismaAlarm.update.mockResolvedValue({
        id: 1,
        isActive: false,
        password: '5678',
        createdAt: new Date(),
        lastActivatedAt: null,
        lastDeactivatedAt: null,
        lastTriggeredAt: null,
      });

      await repository.setPassword('5678');

      expect(mockPrismaAlarm.update).toHaveBeenCalledWith({
        where: { id: 1 },
        data: { password: '5678' },
      });
    });
  });
});
