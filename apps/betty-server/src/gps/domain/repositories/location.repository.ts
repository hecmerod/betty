import { Location } from '../entities/location.entity';

export abstract class LocationRepository {
  abstract add(location: Location): Promise<Location>;
  abstract get(
    from?: Date,
    to?: Date,
    page?: number,
    take?: number
  ): Promise<Location[]>;
}
