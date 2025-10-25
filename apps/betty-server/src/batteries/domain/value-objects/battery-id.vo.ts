export class BatteryId {
  private static readonly VALID_IDS = [1, 2];

  private constructor(private readonly value: number) {
    if (!BatteryId.VALID_IDS.includes(value)) {
      throw new Error(`Invalid battery ID: ${value}. Must be 1 or 2.`);
    }
  }

  static create(value: number): BatteryId {
    return new BatteryId(value);
  }

  getValue(): number {
    return this.value;
  }

  equals(other: BatteryId): boolean {
    return this.value === other.value;
  }

  toString(): string {
    return `Battery ${this.value}`;
  }
}
