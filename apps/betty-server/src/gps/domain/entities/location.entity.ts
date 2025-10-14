export class Location {
  constructor(
    private readonly _latitude: number,
    private readonly _longitude: number,
    private readonly _timestamp: Date = new Date(),
    private readonly _altitude?: number
  ) {
    this.validateCoordinates();
  }

  get latitude(): number {
    return this._latitude;
  }

  get longitude(): number {
    return this._longitude;
  }

  get timestamp(): Date {
    return this._timestamp;
  }

  get altitude(): number | undefined {
    return this._altitude;
  }

  distanceTo(other: Location): number {
    const R = 6371e3;
    const φ1 = (this._latitude * Math.PI) / 180;
    const φ2 = (other._latitude * Math.PI) / 180;
    const Δφ = ((other._latitude - this._latitude) * Math.PI) / 180;
    const Δλ = ((other._longitude - this._longitude) * Math.PI) / 180;

    const a =
      Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
      Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c;
  }

  isWithinRadius(other: Location, radiusInMeters: number): boolean {
    return this.distanceTo(other) <= radiusInMeters;
  }

  private validateCoordinates(): void {
    if (this._latitude < -90 || this._latitude > 90)
      throw new Error('Latitude must be between -90 and 90 degrees');

    if (this._longitude < -180 || this._longitude > 180)
      throw new Error('Longitude must be between -180 and 180 degrees');
  }

  toJSON() {
    return {
      latitude: this._latitude,
      longitude: this._longitude,
      timestamp: this._timestamp.toISOString(),
      altitude: this._altitude,
    };
  }

  toString(): string {
    return `Location(${this._latitude}, ${this._longitude})`;
  }
}
