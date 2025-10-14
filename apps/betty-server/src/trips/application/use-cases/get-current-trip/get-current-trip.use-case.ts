import { Injectable, Inject } from '@nestjs/common';
import { TripRepository } from '../../../domain/repositories/trip.repository';
import { Trip } from '../../../domain/entities/trip.entity';
import { TRIP_REPOSITORY } from '../../../infrastructure/ioc/symbols';

@Injectable()
export class GetCurrentTripUseCase {
  constructor(
    @Inject(TRIP_REPOSITORY)
    private readonly tripRepository: TripRepository
  ) {}

  async execute(): Promise<Trip | null> {
    return this.tripRepository.findCurrent();
  }
}
