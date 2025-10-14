import { Inject, Injectable } from '@nestjs/common';
import { Location } from '../../../domain/entities/location.entity';
import { GpsRepository } from '../../../domain/repositories/gps.repository';
import { GPS_REPOSITORY } from '../../../infrastructure/ioc/symbols';

export interface GetLocationResponse {
  success: boolean;
  location?: Location;
  error?: string;
}

@Injectable()
export class GetLocationUseCase {
  constructor(
    @Inject(GPS_REPOSITORY)
    private readonly gpsRepository: GpsRepository
  ) {}

  async execute(): Promise<GetLocationResponse> {
    try {
      const location = await this.gpsRepository.getCurrentLocation();

      return {
        success: true,
        location: location,
      };
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error ? error.message : 'Failed to get location',
      };
    }
  }
}
