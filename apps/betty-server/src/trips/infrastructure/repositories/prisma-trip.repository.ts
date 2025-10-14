import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../shared/prisma/prisma.service';
import { Trip } from '../../domain/entities/trip.entity';
import {
  TripRepository,
  TripWithLocations,
} from '../../domain/repositories/trip.repository';
import { TripMapper } from '../mappers/trip.mapper';

@Injectable()
export class PrismaTripRepository extends TripRepository {
  constructor(private readonly prisma: PrismaService) {
    super();
  }

  async create(trip: Trip): Promise<Trip> {
    const record = await this.prisma.trip.create({
      data: {
        id: trip.id,
        name: trip.name,
        startedAt: trip.startedAt,
        endedAt: trip.endedAt,
      },
    });

    return TripMapper.toTripEntity(record);
  }

  async findById(
    id: string,
    includeLocations = false
  ): Promise<Trip | TripWithLocations | null> {
    const record = await this.prisma.trip.findUnique({
      where: { id },
      include: includeLocations
        ? {
            locations: {
              orderBy: { recordedAt: 'asc' },
            },
          }
        : undefined,
    });

    if (!record) {
      return null;
    }

    return TripMapper.toDomainEntity(record, includeLocations);
  }

  async findAll(includeLocations = false): Promise<Trip[]> {
    const records = await this.prisma.trip.findMany({
      orderBy: { startedAt: 'desc' },
      include: includeLocations
        ? {
            locations: {
              orderBy: { recordedAt: 'asc' },
            },
          }
        : undefined,
    });

    return records.map((record) =>
      TripMapper.toDomainEntity(record, includeLocations)
    );
  }

  async findCurrent(
    includeLocations = false
  ): Promise<Trip | TripWithLocations | null> {
    const record = await this.prisma.trip.findFirst({
      where: { endedAt: null },
      orderBy: { startedAt: 'desc' },
      include: includeLocations
        ? {
            locations: {
              orderBy: { recordedAt: 'asc' },
            },
          }
        : undefined,
    });

    if (!record) {
      return null;
    }

    return TripMapper.toDomainEntity(record, includeLocations);
  }

  async hasInProgress(): Promise<boolean> {
    const count = await this.prisma.trip.count({
      where: { endedAt: null },
    });

    return count > 0;
  }

  async update(trip: Trip): Promise<Trip> {
    const record = await this.prisma.trip.update({
      where: { id: trip.id },
      data: {},
    });

    return TripMapper.toTripEntity(record);
  }

  async end(id: string): Promise<Trip> {
    const record = await this.prisma.trip.update({
      where: { id },
      data: {
        endedAt: new Date(),
      },
    });

    return TripMapper.toTripEntity(record);
  }
}
