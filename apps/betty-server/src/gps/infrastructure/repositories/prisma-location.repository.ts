import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { PrismaService } from '../../../shared/prisma/prisma.service';
import { Location } from '../../domain/entities/location.entity';
import { LocationRepository } from '../../domain/repositories/location.repository';
import { LocationMapper } from '../mappers/location.mapper';

@Injectable()
export class PrismaLocationRepository extends LocationRepository {
  static readonly PAGE_SIZE = 10;

  constructor(private readonly prisma: PrismaService) {
    super();
  }

  async add(location: Location): Promise<Location> {
    const created = await this.prisma.location.create({
      data: {
        id: randomUUID(),
        latitude: location.latitude,
        longitude: location.longitude,
        altitude: location.altitude,
        recordedAt: location.timestamp,
      },
    });

    return LocationMapper.toDomainEntity(created);
  }

  async get(from: Date, to: Date, page = 1): Promise<Location[]> {
    const currentPage = Math.max(1, page);

    const records = await this.prisma.location.findMany({
      where: {
        recordedAt: {
          gte: from,
          lte: to,
        },
      },
      orderBy: { recordedAt: 'asc' },
      skip: (currentPage - 1) * PrismaLocationRepository.PAGE_SIZE,
      take: PrismaLocationRepository.PAGE_SIZE,
    });

    return LocationMapper.toDomainEntities(records);
  }
}
