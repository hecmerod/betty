export class BmsReadingDto {
  deviceAddress: string;
  batteryId: number;
  totalVoltage: number;
  current: number;
  remainingCapacity: number;
  nominalCapacity: number;
  cycles: number;
  productionDate: string;
  balanceStatus: number[];
  protectionStatus: number;
  softwareVersion: number;
  stateOfCharge: number;
  mosfetStatus: number;
  cellCount: number;
  ntcCount: number;
  temperatures: number[];
  cellVoltages: number[];
  averageCellVoltage: number;
  minCellVoltage: number;
  maxCellVoltage: number;
  voltageDifference: number;
  averageTemperature: number;
  isBalanced: boolean;
  isCharging: boolean;
  isDischarging: boolean;
  timestamp: Date;
}
