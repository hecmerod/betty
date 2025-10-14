import { Trip } from '../entities/trip.entity';
import { TripWithLocations } from '../entities/trip-with-locations.entity';

export { TripWithLocations };

export abstract class TripRepository {
  abstract create(trip: Trip): Promise<Trip>;
  abstract findById(
    id: string,
    includeLocations?: boolean
  ): Promise<Trip | TripWithLocations | null>;
  abstract findAll(includeLocations?: boolean): Promise<Trip[]>;
  abstract findCurrent(
    includeLocations?: boolean
  ): Promise<Trip | TripWithLocations | null>;
  abstract hasInProgress(): Promise<boolean>;
  abstract update(trip: Trip): Promise<Trip>;
  abstract end(id: string): Promise<Trip>;
}
