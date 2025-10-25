export class MacAddress {
  private constructor(private readonly value: string) {
    if (!MacAddress.isValid(value)) {
      throw new Error(`Invalid MAC address: ${value}`);
    }
  }

  static create(value: string): MacAddress {
    return new MacAddress(value);
  }

  static isValid(value: string): boolean {
    const macRegex = /^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/;
    return macRegex.test(value);
  }

  getValue(): string {
    return this.value;
  }

  equals(other: MacAddress): boolean {
    return this.value.toLowerCase() === other.value.toLowerCase();
  }

  toString(): string {
    return this.value;
  }
}
