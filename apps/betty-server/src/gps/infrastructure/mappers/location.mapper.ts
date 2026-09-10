import { Location as PrismaLocation } from '@prisma/client';
import { Location } from '../../domain/entities/location.entity';

export class LocationMapper {
  static toDomainEntity(prismaLocation: PrismaLocation): Location {
    return new Location(
      prismaLocation.latitude,
      prismaLocation.longitude,
      prismaLocation.recordedAt,
      prismaLocation.altitude ?? undefined
    );
  }

  static toDomainEntities(prismaLocations: PrismaLocation[]): Location[] {
    return prismaLocations.map((loc) => LocationMapper.toDomainEntity(loc));
  }
}
