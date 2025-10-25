export class BmsReading {
  constructor(
    public readonly deviceAddress: string,
    public readonly batteryId: number,
    public readonly totalVoltage: number,
    public readonly current: number,
    public readonly remainingCapacity: number,
    public readonly nominalCapacity: number,
    public readonly cycles: number,
    public readonly productionDate: string,
    public readonly balanceStatus: number[],
    public readonly protectionStatus: number,
    public readonly softwareVersion: number,
    public readonly stateOfCharge: number,
    public readonly mosfetStatus: number,
    public readonly cellCount: number,
    public readonly ntcCount: number,
    public readonly temperatures: number[],
    public readonly cellVoltages: number[],
    public readonly timestamp: Date
  ) {}

  get averageCellVoltage(): number {
    return (
      this.cellVoltages.reduce((sum, v) => sum + v, 0) /
      this.cellVoltages.length
    );
  }

  get minCellVoltage(): number {
    return Math.min(...this.cellVoltages);
  }

  get maxCellVoltage(): number {
    return Math.max(...this.cellVoltages);
  }

  get voltageDifference(): number {
    return this.maxCellVoltage - this.minCellVoltage;
  }

  get averageTemperature(): number {
    return (
      this.temperatures.reduce((sum, t) => sum + t, 0) /
      this.temperatures.length
    );
  }

  get isBalanced(): boolean {
    return this.voltageDifference < 0.05; // 50mV
  }

  get isCharging(): boolean {
    return this.current > 0;
  }

  get isDischarging(): boolean {
    return this.current < 0;
  }

  toJSON() {
    return {
      deviceAddress: this.deviceAddress,
      batteryId: this.batteryId,
      totalVoltage: this.totalVoltage,
      current: this.current,
      remainingCapacity: this.remainingCapacity,
      nominalCapacity: this.nominalCapacity,
      cycles: this.cycles,
      productionDate: this.productionDate,
      balanceStatus: this.balanceStatus,
      protectionStatus: this.protectionStatus,
      softwareVersion: this.softwareVersion,
      stateOfCharge: this.stateOfCharge,
      mosfetStatus: this.mosfetStatus,
      cellCount: this.cellCount,
      ntcCount: this.ntcCount,
      temperatures: this.temperatures,
      cellVoltages: this.cellVoltages,
      averageCellVoltage: this.averageCellVoltage,
      minCellVoltage: this.minCellVoltage,
      maxCellVoltage: this.maxCellVoltage,
      voltageDifference: this.voltageDifference,
      averageTemperature: this.averageTemperature,
      isBalanced: this.isBalanced,
      isCharging: this.isCharging,
      isDischarging: this.isDischarging,
      timestamp: this.timestamp,
    };
  }
}
