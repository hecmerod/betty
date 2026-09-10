import { Inject, Injectable } from '@nestjs/common';
import { Location } from '../../../domain/entities/location.entity';
import { LocationRepository } from '../../../domain/repositories/location.repository';
import { LOCATION_REPOSITORY } from '../../../infrastructure/ioc/symbols';

@Injectable()
export class GetLocationsUseCase {
  constructor(
    @Inject(LOCATION_REPOSITORY)
    private readonly locationRepository: LocationRepository
  ) {}

  async execute(from: Date, to: Date, page = 1): Promise<Location[]> {
    return this.locationRepository.get(from, to, page);
  }
}
