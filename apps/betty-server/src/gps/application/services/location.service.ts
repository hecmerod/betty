import {
  Inject,
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { TriggerAlarmUseCase } from '../../../alarm/application/use-cases/trigger-alarm/trigger-alarm.use-case';
import { SENSOR_REPOSITORY } from '../../../alarm/infrastructure/ioc/symbols';
import { SensorRepository } from '../../../alarm/domain/repositories/sensor.repository';
import { LocationRepository } from '../../domain/repositories/location.repository';
import { LOCATION_REPOSITORY } from '../../infrastructure/ioc/symbols';
import { GetLastLocationUseCase } from '../use-cases/get-last-location/get-last-location.use-case';
import { GetLocationUseCase } from '../use-cases/get-location/get-location.use-case';

@Injectable()
export class LocationService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(LocationService.name);
  private readonly SENSOR_ID = 'location' as const;
  private readonly CHECK_INTERVAL_MS = 5 * 60 * 1000;
  private readonly MOVEMENT_THRESHOLD_METERS = 20;
  private trackingTimeout?: NodeJS.Timeout;
  private isChecking = false;
  private isMonitoring = false;

  constructor(
    private readonly getLocationUseCase: GetLocationUseCase,
    private readonly getLastLocationUseCase: GetLastLocationUseCase,
    @Inject(LOCATION_REPOSITORY)
    private readonly locationRepository: LocationRepository,
    @Inject(SENSOR_REPOSITORY)
    private readonly sensorRepository: SensorRepository,
    private readonly triggerAlarmUseCase: TriggerAlarmUseCase
  ) {}

  async onModuleInit() {
    const isListening = await this.sensorRepository.isListening(this.SENSOR_ID);

    if (isListening) this.startMonitoring();
  }

  async onModuleDestroy() {
    this.stopMonitoring();
  }

  async enableMonitoring(): Promise<void> {
    const isListening = await this.sensorRepository.isListening(this.SENSOR_ID);

    if (isListening) return;

    await this.sensorRepository.enableListening(this.SENSOR_ID);
    this.startMonitoring();
  }

  async disableMonitoring(): Promise<void> {
    const isListening = await this.sensorRepository.isListening(this.SENSOR_ID);

    if (!isListening) return;

    await this.sensorRepository.disableListening(this.SENSOR_ID);
    this.stopMonitoring();
  }

  private startMonitoring(): void {
    this.isMonitoring = true;
    this.scheduleNextCheck(0);
    this.logger.log('Started monitoring for Location');
  }

  private stopMonitoring(): void {
    this.isMonitoring = false;
    if (this.trackingTimeout) {
      clearTimeout(this.trackingTimeout);
      this.trackingTimeout = undefined;
    }
    this.logger.log('Location monitoring stopped');
  }

  private scheduleNextCheck(delayMs = this.CHECK_INTERVAL_MS): void {
    if (this.trackingTimeout) clearTimeout(this.trackingTimeout);

    this.trackingTimeout = setTimeout(() => {
      this.checkLocation();
    }, delayMs);
  }

  async checkLocation(): Promise<void> {
    if (this.isChecking) return this.scheduleNextCheck();

    try {
      this.isChecking = true;

      const isListening = await this.sensorRepository.isListening(
        this.SENSOR_ID
      );

      if (!isListening) return;

      const { success, location } = await this.getLocationUseCase.execute();

      if (!success || !location) return;

      const lastLocation = await this.getLastLocationUseCase.execute();

      if (!lastLocation) {
        await this.locationRepository.add(location);        
        return;
      }

      const distance = location.distanceTo(lastLocation);

      if (distance <= this.MOVEMENT_THRESHOLD_METERS) return;      

      await this.locationRepository.add(location);

      if (process.env.NODE_ENV === 'production')
        await this.triggerAlarmUseCase.execute({
          eventType: 'location_moved',
          detectionType: 'location',
          metadata: { distanceMeters: distance },
        });
    } catch (error) {
      this.logger.error(
        `Location monitoring error: ${
          error instanceof Error ? error.message : error
        }`
      );
    } finally {
      this.isChecking = false;
      if (this.isMonitoring) this.scheduleNextCheck();
    }
  }
}
