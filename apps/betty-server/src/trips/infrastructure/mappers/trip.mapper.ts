import {
  Trip as PrismaTrip,
  TripLocation as PrismaTripLocation,
} from '@prisma/client';
import { LocationMapper } from '../../../gps/infrastructure/mappers/location.mapper';
import { Trip } from '../../domain/entities/trip.entity';
import { TripWithLocations } from '../../domain/entities/trip-with-locations.entity';

export class TripMapper {
  static toTripEntity(prismaTrip: PrismaTrip): Trip {
    return new Trip(
      prismaTrip.id,
      prismaTrip.name,
      prismaTrip.startedAt,
      prismaTrip.endedAt ?? undefined,
      prismaTrip.createdAt,
      prismaTrip.updatedAt
    );
  }

  static toTripWithLocations(
    prismaTrip: PrismaTrip & { locations: PrismaTripLocation[] }
  ): TripWithLocations {
    const locations = LocationMapper.toDomainEntities(prismaTrip.locations);

    return new TripWithLocations(
      prismaTrip.id,
      prismaTrip.name,
      prismaTrip.startedAt,
      prismaTrip.endedAt ?? undefined,
      prismaTrip.createdAt,
      prismaTrip.updatedAt,
      locations
    );
  }

  static toDomainEntity(
    prismaTrip: PrismaTrip & { locations?: PrismaTripLocation[] },
    includeLocations: boolean
  ): Trip | TripWithLocations {
    if (includeLocations && prismaTrip.locations) {
      return TripMapper.toTripWithLocations({
        ...prismaTrip,
        locations: prismaTrip.locations,
      });
    }

    return TripMapper.toTripEntity(prismaTrip);
  }
}
