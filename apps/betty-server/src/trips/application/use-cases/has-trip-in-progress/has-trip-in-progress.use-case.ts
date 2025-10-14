import { Injectable, Inject } from '@nestjs/common';
import { TripRepository } from '../../../domain/repositories/trip.repository';
import { TRIP_REPOSITORY } from '../../../infrastructure/ioc/symbols';

@Injectable()
export class HasTripInProgressUseCase {
  constructor(
    @Inject(TRIP_REPOSITORY)
    private readonly tripRepository: TripRepository
  ) {}

  async execute(): Promise<{ hasInProgress: boolean }> {
    const hasInProgress = await this.tripRepository.hasInProgress();
    return { hasInProgress };
  }
}
