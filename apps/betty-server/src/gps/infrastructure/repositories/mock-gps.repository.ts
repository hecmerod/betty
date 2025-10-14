import { Injectable } from '@nestjs/common';
import { GpsRepository } from '../../domain/repositories/gps.repository';
import { Location } from '../../domain/entities/location.entity';

@Injectable()
export class MockGpsRepository extends GpsRepository {
  private readonly MOCK_LATITUDE = 40.4168;
  private readonly MOCK_LONGITUDE = -3.7038;
  private readonly MOCK_ALTITUDE = 650;

  async getCurrentLocation(): Promise<Location> {
    const latitudeVariation = (Math.random() - 0.5) * 0.001;
    const longitudeVariation = (Math.random() - 0.5) * 0.001;
    const altitudeVariation = Math.floor((Math.random() - 0.5) * 20);

    return new Location(
      this.MOCK_LATITUDE + latitudeVariation,
      this.MOCK_LONGITUDE + longitudeVariation,
      new Date(),
      this.MOCK_ALTITUDE + altitudeVariation
    );
  }
}
