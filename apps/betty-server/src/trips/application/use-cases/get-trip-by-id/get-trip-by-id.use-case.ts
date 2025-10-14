import { Inject, Injectable } from '@nestjs/common';
import { Trip } from '../../../domain/entities/trip.entity';
import {
  TripRepository,
  TripWithLocations,
} from '../../../domain/repositories/trip.repository';
import { TRIP_REPOSITORY } from '../../../infrastructure/ioc/symbols';

@Injectable()
export class GetTripByIdUseCase {
  constructor(
    @Inject(TRIP_REPOSITORY)
    private readonly tripRepository: TripRepository
  ) {}

  async execute(
    id: string,
    includeLocations = false
  ): Promise<Trip | TripWithLocations | null> {
    return this.tripRepository.findById(id, includeLocations);
  }
}
