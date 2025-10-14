import { Injectable } from '@nestjs/common';
import { Location } from '../../../gps/domain/entities/location.entity';
import { LocationMapper } from '../../../gps/infrastructure/mappers/location.mapper';
import { PrismaService } from '../../../shared/prisma/prisma.service';
import { TripLocationRepository } from '../../domain/repositories/trip-location.repository';

@Injectable()
export class PrismaTripLocationRepository implements TripLocationRepository {
  constructor(private readonly prisma: PrismaService) {}

  async addLocation(tripId: string, location: Location): Promise<Location> {
    const created = await this.prisma.tripLocation.create({
      data: {
        id: crypto.randomUUID(),
        tripId: tripId,
        latitude: location.latitude,
        longitude: location.longitude,
        altitude: location.altitude,
        recordedAt: location.timestamp,
      },
    });

    return LocationMapper.toDomainEntity(created);
  }

  async getLocationsByTripId(tripId: string): Promise<Location[]> {
    const locations = await this.prisma.tripLocation.findMany({
      where: { tripId },
      orderBy: { recordedAt: 'asc' },
    });

    return LocationMapper.toDomainEntities(locations);
  }

  async getLatestLocation(tripId: string): Promise<Location | null> {
    const location = await this.prisma.tripLocation.findFirst({
      where: { tripId },
      orderBy: { recordedAt: 'desc' },
    });

    if (!location) {
      return null;
    }

    return LocationMapper.toDomainEntity(location);
  }

  async countLocations(tripId: string): Promise<number> {
    return this.prisma.tripLocation.count({
      where: { tripId },
    });
  }
}
