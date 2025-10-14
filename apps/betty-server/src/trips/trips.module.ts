import { Module } from '@nestjs/common';
import { TripsController } from './presentation/controllers/trips.controller';
import { CreateTripUseCase } from './application/use-cases/create-trip/create-trip.use-case';
import { EndTripUseCase } from './application/use-cases/end-trip/end-trip.use-case';
import { GetCurrentTripUseCase } from './application/use-cases/get-current-trip/get-current-trip.use-case';
import { GetAllTripsUseCase } from './application/use-cases/get-all-trips/get-all-trips.use-case';
import { GetTripByIdUseCase } from './application/use-cases/get-trip-by-id/get-trip-by-id.use-case';
import { HasTripInProgressUseCase } from './application/use-cases/has-trip-in-progress/has-trip-in-progress.use-case';
import { PrismaTripRepository } from './infrastructure/repositories/prisma-trip.repository';
import { TRIP_REPOSITORY } from './infrastructure/ioc/symbols';

@Module({
  controllers: [TripsController],
  providers: [
    CreateTripUseCase,
    EndTripUseCase,
    GetCurrentTripUseCase,
    GetAllTripsUseCase,
    GetTripByIdUseCase,
    HasTripInProgressUseCase,
    {
      provide: TRIP_REPOSITORY,
      useClass: PrismaTripRepository,
    },
  ],
  exports: [
    CreateTripUseCase,
    EndTripUseCase,
    GetCurrentTripUseCase,
    GetAllTripsUseCase,
    GetTripByIdUseCase,
    HasTripInProgressUseCase,
    TRIP_REPOSITORY,
  ],
})
export class TripsModule {}
