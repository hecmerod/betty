import { TripLocation as PrismaTripLocation } from '@prisma/client';
import { Location } from '../../domain/entities/location.entity';

export class LocationMapper {
  static toDomainEntity(prismaLocation: PrismaTripLocation): Location {
    return new Location(
      prismaLocation.latitude,
      prismaLocation.longitude,
      prismaLocation.recordedAt,
      prismaLocation.altitude ?? undefined
    );
  }

  static toDomainEntities(prismaLocations: PrismaTripLocation[]): Location[] {
    return prismaLocations.map((loc) => LocationMapper.toDomainEntity(loc));
  }
}
