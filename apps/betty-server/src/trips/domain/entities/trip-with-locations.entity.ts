import { Location } from '../../../gps/domain/entities/location.entity';
import { Trip } from './trip.entity';

export class TripWithLocations extends Trip {
  constructor(
    id: string,
    name: string,
    startedAt: Date,
    endedAt: Date | undefined,
    createdAt: Date,
    updatedAt: Date,
    public readonly locations: Location[]
  ) {
    super(id, name, startedAt, endedAt, createdAt, updatedAt);
  }

  override toJSON() {
    return {
      ...super.toJSON(),
      locations: this.locations.map((location) => location.toJSON()),
    };
  }
}
