export interface GpsReading {
  latitude: number;
  longitude: number;
  altitude?: number;
  timestamp: Date;
}

export interface IGpsPort {
  readLocation(): Promise<GpsReading>;
}
