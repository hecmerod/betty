import { Injectable, Inject } from '@nestjs/common';
import { GpsRepository } from '../../../domain/repositories/gps.repository';
import { GPS_REPOSITORY } from '../../../infrastructure/ioc/symbols';

export interface GetLocationResponse {
  success: boolean;
  location?: {
    latitude: number;
    longitude: number;
    timestamp: string;
    altitude?: number;
  };
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
        location: {
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: location.timestamp.toISOString(),
          altitude: location.altitude,
        },
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
