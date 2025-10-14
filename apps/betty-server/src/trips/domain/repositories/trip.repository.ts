import { Trip } from '../entities/trip.entity';

export abstract class TripRepository {
  abstract create(trip: Trip): Promise<Trip>;
  abstract findById(id: string): Promise<Trip | null>;
  abstract findAll(): Promise<Trip[]>;
  abstract findCurrent(): Promise<Trip | null>;
  abstract hasInProgress(): Promise<boolean>;
  abstract update(trip: Trip): Promise<Trip>;
  abstract end(id: string): Promise<Trip>;
}
