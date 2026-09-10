import { Inject, Injectable } from '@nestjs/common';
import { Location } from '../../../domain/entities/location.entity';
import { LocationRepository } from '../../../domain/repositories/location.repository';
import { LOCATION_REPOSITORY } from '../../../infrastructure/ioc/symbols';

@Injectable()
export class GetLastLocationUseCase {
  constructor(
    @Inject(LOCATION_REPOSITORY)
    private readonly locationRepository: LocationRepository
  ) {}

  async execute(): Promise<Location | null> {
    const [location] = await this.locationRepository.get(
      undefined,
      undefined,
      1,
      1
    );

    return location ?? null;
  }
}
