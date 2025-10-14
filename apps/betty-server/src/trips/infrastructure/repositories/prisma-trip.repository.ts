import { Injectable } from '@nestjs/common';
import { TripRepository } from '../../domain/repositories/trip.repository';
import { Trip } from '../../domain/entities/trip.entity';
import { PrismaService } from '../../../shared/prisma/prisma.service';

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

    return new Trip(
      record.id,
      record.name,
      record.startedAt,
      record.endedAt ?? undefined,
      record.createdAt,
      record.updatedAt
    );
  }

  async findById(id: string): Promise<Trip | null> {
    const record = await this.prisma.trip.findUnique({
      where: { id },
    });

    if (!record) {
      return null;
    }

    return new Trip(
      record.id,
      record.name,
      record.startedAt,
      record.endedAt ?? undefined,
      record.createdAt,
      record.updatedAt
    );
  }

  async findAll(): Promise<Trip[]> {
    const records = await this.prisma.trip.findMany({
      orderBy: { startedAt: 'desc' },
    });

    return records.map(
      (record) =>
        new Trip(
          record.id,
          record.name,
          record.startedAt,
          record.endedAt ?? undefined,
          record.createdAt,
          record.updatedAt
        )
    );
  }

  async findCurrent(): Promise<Trip | null> {
    const record = await this.prisma.trip.findFirst({
      where: { endedAt: null },
      orderBy: { startedAt: 'desc' },
    });

    if (!record) {
      return null;
    }

    return new Trip(
      record.id,
      record.name,
      record.startedAt,
      record.endedAt ?? undefined,
      record.createdAt,
      record.updatedAt
    );
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

    return new Trip(
      record.id,
      record.name,
      record.startedAt,
      record.endedAt ?? undefined,
      record.createdAt,
      record.updatedAt
    );
  }

  async end(id: string): Promise<Trip> {
    const record = await this.prisma.trip.update({
      where: { id },
      data: {
        endedAt: new Date(),
      },
    });

    return new Trip(
      record.id,
      record.name,
      record.startedAt,
      record.endedAt ?? undefined,
      record.createdAt,
      record.updatedAt
    );
  }
}
