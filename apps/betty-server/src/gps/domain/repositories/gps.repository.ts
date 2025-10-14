import { Location } from '../entities/location.entity';

export abstract class GpsRepository {
  abstract getCurrentLocation(): Promise<Location>;
}
