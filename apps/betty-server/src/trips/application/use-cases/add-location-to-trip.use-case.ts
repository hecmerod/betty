import { Inject, Injectable } from '@nestjs/common';
import { Location } from '../../../gps/domain/entities/location.entity';
import {
  TRIP_LOCATION_REPOSITORY,
  TRIP_REPOSITORY,
} from '../../domain/repositories/symbols';
import { TripLocationRepository } from '../../domain/repositories/trip-location.repository';
import { TripRepository } from '../../domain/repositories/trip.repository';

export interface AddLocationResult {
  saved: boolean;
  reason?: string;
  distanceFromLast?: number;
  location?: Location;
}

@Injectable()
export class AddLocationToTripUseCase {
  constructor(
    @Inject(TRIP_REPOSITORY)
    private readonly tripRepository: TripRepository,
    @Inject(TRIP_LOCATION_REPOSITORY)
    private readonly tripLocationRepository: TripLocationRepository
  ) {}

  async execute(
    location: Location,
    minDistanceMeters = 10
  ): Promise<AddLocationResult> {
    const currentTrip = await this.tripRepository.findCurrent();

    if (!currentTrip) {
      return {
        saved: false,
        reason: 'No hay un viaje en progreso',
      };
    }

    const lastLocation = await this.tripLocationRepository.getLatestLocation(
      currentTrip.id
    );

    if (!lastLocation) {
      const saved = await this.tripLocationRepository.addLocation(
        currentTrip.id,
        location
      );
      return {
        saved: true,
        location: saved,
      };
    }

    const distance = location.distanceTo(lastLocation);

    if (distance < minDistanceMeters) {
      return {
        saved: false,
        reason: `Cambio insignificante: ${distance.toFixed(
          2
        )}m < ${minDistanceMeters}m`,
        distanceFromLast: distance,
      };
    }

    const saved = await this.tripLocationRepository.addLocation(
      currentTrip.id,
      location
    );

    return {
      saved: true,
      distanceFromLast: distance,
      location: saved,
    };
  }
}
