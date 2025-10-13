import { InMemoryAlarmRepository } from '../in-memory-alarm.repository';
import { Alarm } from '../../../domain/entities/alarm.entity';

describe('InMemoryAlarmRepository', () => {
  let repository: InMemoryAlarmRepository;

  beforeEach(() => {
    repository = new InMemoryAlarmRepository();
  });

  it('should be defined', () => {
    expect(repository).toBeDefined();
  });

  describe('get', () => {
    it('should return the alarm instance', async () => {
      const alarm = await repository.get();

      expect(alarm).toBeInstanceOf(Alarm);
      expect(alarm.isActive).toBe(false);
      expect(alarm.status).toBe('inactive');
    });

    it('should return the same alarm instance on multiple calls', async () => {
      const alarm1 = await repository.get();
      const alarm2 = await repository.get();

      expect(alarm1).toBe(alarm2);
    });
  });

  describe('activate', () => {
    it('should activate the alarm', async () => {
      await repository.activate();
      const alarm = await repository.get();

      expect(alarm.isActive).toBe(true);
      expect(alarm.status).toBe('active');
      expect(alarm.lastActivatedAt).toBeInstanceOf(Date);
    });

    it('should throw error when activating already active alarm', async () => {
      await repository.activate();

      await expect(repository.activate()).rejects.toThrow(
        'Alarm is already active'
      );
    });

    it('should update lastActivatedAt timestamp', async () => {
      const beforeActivation = Date.now();
      await repository.activate();
      const alarm = await repository.get();

      expect(alarm.lastActivatedAt?.getTime()).toBeGreaterThanOrEqual(
        beforeActivation
      );
    });
  });

  describe('deactivate', () => {
    it('should deactivate the alarm', async () => {
      await repository.activate();
      await repository.deactivate();
      const alarm = await repository.get();

      expect(alarm.isActive).toBe(false);
      expect(alarm.status).toBe('inactive');
      expect(alarm.lastDeactivatedAt).toBeInstanceOf(Date);
    });

    it('should throw error when deactivating inactive alarm', async () => {
      await expect(repository.deactivate()).rejects.toThrow(
        'Alarm is already inactive'
      );
    });

    it('should update lastDeactivatedAt timestamp', async () => {
      await repository.activate();
      const beforeDeactivation = Date.now();
      await repository.deactivate();
      const alarm = await repository.get();

      expect(alarm.lastDeactivatedAt?.getTime()).toBeGreaterThanOrEqual(
        beforeDeactivation
      );
    });
  });

  describe('alarm state persistence', () => {
    it('should maintain alarm state across method calls', async () => {
      // Initial state
      let alarm = await repository.get();
      expect(alarm.isActive).toBe(false);

      // Activate
      await repository.activate();
      alarm = await repository.get();
      expect(alarm.isActive).toBe(true);

      // Deactivate
      await repository.deactivate();
      alarm = await repository.get();
      expect(alarm.isActive).toBe(false);
    });

    it('should maintain timestamps across method calls', async () => {
      await repository.activate();
      const alarm1 = await repository.get();
      const activatedAt1 = alarm1.lastActivatedAt;

      // Wait a bit
      await new Promise((resolve) => setTimeout(resolve, 10));

      const alarm2 = await repository.get();
      const activatedAt2 = alarm2.lastActivatedAt;

      // Timestamps should be the same since we didn't reactivate
      expect(activatedAt1).toBe(activatedAt2);
    });

    it('should allow reactivation after deactivation', async () => {
      await repository.activate();
      await repository.deactivate();
      await repository.activate();

      const alarm = await repository.get();
      expect(alarm.isActive).toBe(true);
      expect(alarm.lastActivatedAt).toBeInstanceOf(Date);
      expect(alarm.lastDeactivatedAt).toBeInstanceOf(Date);
    });
  });

  describe('alarm lifecycle', () => {
    it('should handle complete alarm lifecycle', async () => {
      // Start inactive
      let alarm = await repository.get();
      expect(alarm.isActive).toBe(false);
      expect(alarm.lastActivatedAt).toBeUndefined();
      expect(alarm.lastDeactivatedAt).toBeUndefined();

      // Activate
      await repository.activate();
      alarm = await repository.get();
      expect(alarm.isActive).toBe(true);
      expect(alarm.lastActivatedAt).toBeInstanceOf(Date);
      expect(alarm.lastDeactivatedAt).toBeUndefined();

      // Deactivate
      await repository.deactivate();
      alarm = await repository.get();
      expect(alarm.isActive).toBe(false);
      expect(alarm.lastActivatedAt).toBeInstanceOf(Date);
      expect(alarm.lastDeactivatedAt).toBeInstanceOf(Date);

      // Reactivate
      await repository.activate();
      alarm = await repository.get();
      expect(alarm.isActive).toBe(true);
    });
  });
});
