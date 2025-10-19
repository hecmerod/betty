import { Module } from '@nestjs/common';
import { GpsModule } from '../gps/gps.module';
import { AddLocationToTripUseCase } from './application/use-cases/add-location-to-trip.use-case';
import { CreateTripUseCase } from './application/use-cases/create-trip/create-trip.use-case';
import { EndTripUseCase } from './application/use-cases/end-trip/end-trip.use-case';
import { GetAllTripsUseCase } from './application/use-cases/get-all-trips/get-all-trips.use-case';
import { GetCurrentTripUseCase } from './application/use-cases/get-current-trip/get-current-trip.use-case';
import { GetTripByIdUseCase } from './application/use-cases/get-trip-by-id/get-trip-by-id.use-case';
import { HasTripInProgressUseCase } from './application/use-cases/has-trip-in-progress/has-trip-in-progress.use-case';

import { PrismaTripLocationRepository } from './infrastructure/repositories/prisma-trip-location.repository';
import { PrismaTripRepository } from './infrastructure/repositories/prisma-trip.repository';
import { TripTrackingService } from './infrastructure/services/trip-tracking.service';
import { TripsController } from './presentation/controllers/trips.controller';
import {
  TRIP_LOCATION_REPOSITORY,
  TRIP_REPOSITORY,
} from './infrastructure/ioc/symbols';

@Module({
  imports: [GpsModule],
  controllers: [TripsController],
  providers: [
    CreateTripUseCase,
    EndTripUseCase,
    GetCurrentTripUseCase,
    GetAllTripsUseCase,
    GetTripByIdUseCase,
    HasTripInProgressUseCase,
    AddLocationToTripUseCase,
    {
      provide: TRIP_REPOSITORY,
      useClass: PrismaTripRepository,
    },
    {
      provide: TRIP_LOCATION_REPOSITORY,
      useClass: PrismaTripLocationRepository,
    },
    TripTrackingService,
  ],
  exports: [
    CreateTripUseCase,
    EndTripUseCase,
    GetCurrentTripUseCase,
    GetAllTripsUseCase,
    GetTripByIdUseCase,
    HasTripInProgressUseCase,
    AddLocationToTripUseCase,
    TRIP_REPOSITORY,
    TRIP_LOCATION_REPOSITORY,
  ],
})
export class TripsModule {}
