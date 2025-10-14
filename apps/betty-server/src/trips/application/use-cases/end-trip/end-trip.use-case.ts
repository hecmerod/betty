import { Injectable, Inject } from '@nestjs/common';
import { TripRepository } from '../../../domain/repositories/trip.repository';
import { Trip } from '../../../domain/entities/trip.entity';
import { TRIP_REPOSITORY } from '../../../infrastructure/ioc/symbols';

@Injectable()
export class EndTripUseCase {
  constructor(
    @Inject(TRIP_REPOSITORY)
    private readonly tripRepository: TripRepository
  ) {}

  async execute(id: string): Promise<Trip> {
    const trip = await this.tripRepository.findById(id);

    if (!trip) {
      throw new Error('Trip not found');
    }

    if (trip.isCompleted) {
      throw new Error('Trip is already completed');
    }

    return this.tripRepository.end(id);
  }
}
