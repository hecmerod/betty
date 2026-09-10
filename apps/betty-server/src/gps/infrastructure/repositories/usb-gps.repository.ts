import { Inject, Injectable } from '@nestjs/common';
import { Location } from '../../domain/entities/location.entity';
import { IGpsPort } from '../../domain/ports/gps.port';
import { GpsRepository } from '../../domain/repositories/gps.repository';
import { GPS_ADAPTER } from '../ioc/symbols';

@Injectable()
export class UsbGpsRepository extends GpsRepository {
  constructor(
    @Inject(GPS_ADAPTER)
    private readonly gpsPort: IGpsPort
  ) {
    super();
  }

  async getCurrentLocation(): Promise<Location> {
    const reading = await this.gpsPort.readLocation();

    return new Location(
      reading.latitude,
      reading.longitude,
      reading.timestamp,
      reading.altitude
    );
  }
}
