import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { GetLocationUseCase } from '../../../gps/application/use-cases/get-location/get-location.use-case';
import { AddLocationToTripUseCase } from '../../application/use-cases/add-location-to-trip.use-case';

@Injectable()
export class TripTrackingService implements OnModuleInit {
  private readonly logger = new Logger(TripTrackingService.name);
  private isTracking = false;
  private trackingTimeout?: NodeJS.Timeout;
  private currentInterval = 30000;
  private readonly ACTIVE_INTERVAL = 30000;
  private readonly IDLE_INTERVAL = 300000;

  constructor(
    private readonly getLocationUseCase: GetLocationUseCase,
    private readonly addLocationToTripUseCase: AddLocationToTripUseCase
  ) {}

  onModuleInit() {
    this.scheduleNextCheck();
    this.logger.log('Servicio de tracking iniciado');
  }

  private scheduleNextCheck(): void {
    if (this.trackingTimeout) clearTimeout(this.trackingTimeout);

    this.trackingTimeout = setTimeout(() => {
      this.trackCurrentTrip();
    }, this.currentInterval);
  }

  async trackCurrentTrip(): Promise<void> {
    if (this.isTracking) return this.scheduleNextCheck();

    try {
      this.isTracking = true;

      const { success, location } = await this.getLocationUseCase.execute();

      if (!success || !location) return;

      const result = await this.addLocationToTripUseCase.execute(location);

      this.currentInterval = result.saved
        ? this.ACTIVE_INTERVAL
        : this.IDLE_INTERVAL;
    } catch {
      this.currentInterval = this.ACTIVE_INTERVAL;
    } finally {
      this.isTracking = false;
      this.scheduleNextCheck();
    }
  }

  stopTracking(): void {
    if (this.trackingTimeout) {
      clearTimeout(this.trackingTimeout);
      this.trackingTimeout = undefined;
    }
  }
}
