import { Injectable, Inject } from '@nestjs/common';
import { TripRepository } from '../../../domain/repositories/trip.repository';
import { Trip } from '../../../domain/entities/trip.entity';
import { TRIP_REPOSITORY } from '../../../infrastructure/ioc/symbols';
import { randomUUID } from 'crypto';

@Injectable()
export class CreateTripUseCase {
  constructor(
    @Inject(TRIP_REPOSITORY)
    private readonly tripRepository: TripRepository
  ) {}

  async execute(name: string): Promise<Trip> {
    // Verificar que no haya un viaje en progreso
    const hasInProgress = await this.tripRepository.hasInProgress();
    if (hasInProgress) {
      throw new Error('There is already a trip in progress');
    }

    // Crear nuevo viaje
    const trip = new Trip(
      randomUUID(),
      name,
      new Date() // startedAt
    );

    return this.tripRepository.create(trip);
  }
}
