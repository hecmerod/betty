export class VehicleData {
  constructor(
    public readonly rpm: number | null,
    public readonly speed: number | null,
    public readonly engineLoad: number | null,
    public readonly coolantTemp: number | null,
    public readonly fuelLevel: number | null,
    public readonly throttlePosition: number | null,
    public readonly intakeTemp: number | null,
    public readonly maf: number | null, // Mass Air Flow
    public readonly voltage: number | null,
    public readonly timestamp: Date
  ) {}

  toJSON() {
    return {
      rpm: this.rpm,
      speed: this.speed,
      engineLoad: this.engineLoad,
      coolantTemp: this.coolantTemp,
      fuelLevel: this.fuelLevel,
      throttlePosition: this.throttlePosition,
      intakeTemp: this.intakeTemp,
      maf: this.maf,
      voltage: this.voltage,
      timestamp: this.timestamp.toISOString(),
    };
  }
}
