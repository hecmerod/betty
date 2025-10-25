import { Logger } from '@nestjs/common';
import { BmsRawData } from '../ble/bms-ble.client';

export interface ParsedBmsData {
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
}

export class Dp04sProtocolParser {
  private readonly logger = new Logger(Dp04sProtocolParser.name);

  parse(rawData: BmsRawData): ParsedBmsData {
    const basicInfo = this.parseBasicInfo(rawData.basicInfo);
    const cellVoltages = this.parseCellVoltages(rawData.cellVoltages);

    return {
      ...basicInfo,
      cellVoltages,
    };
  }

  private parseBasicInfo(data: Buffer) {
    if (data.length < 34)
      throw new Error(`Invalid basic info data: only ${data.length} bytes`);

    // Protocolo JBD/DP04S comando 0x03:
    // 0-1: Header (DD 03)
    // 2-3: Data length
    // 4-5: Total voltage (0.01V)
    // 6-7: Current (0.01A, signed)
    // 8-9: Remaining capacity (0.01Ah)
    // 10-11: Nominal capacity (0.01Ah)
    // 12-13: Cycles
    // 14-15: Production date
    // 16-17: Balance status (bits)
    // 18-19: Protection status
    // 20: Software version
    // 21: State of charge (%)
    // 22: MOSFET status
    // 23: Cell count
    // 24: NTC count
    // 25+: Temperatures (0.1K - 2731 = °C)

    const totalVoltage = data.readUInt16BE(4) / 100;
    const current = data.readInt16BE(6) / 100;
    const remainingCapacity = data.readUInt16BE(8) / 100;
    const nominalCapacity = data.readUInt16BE(10) / 100;
    const cycles = data.readUInt16BE(12);

    const prodDateRaw = data.readUInt16BE(14);
    const day = prodDateRaw & 0x1f;
    const month = (prodDateRaw >> 5) & 0x0f;
    const year = 2000 + (prodDateRaw >> 9);
    const productionDate = `${year}-${String(month).padStart(2, '0')}-${String(
      day
    ).padStart(2, '0')}`;

    const balanceStatus1 = data.readUInt8(16);
    const balanceStatus2 = data.readUInt8(17);
    const balanceStatus = [balanceStatus1, balanceStatus2];

    const protectionStatus = data.readUInt16BE(18);
    const softwareVersion = data.readUInt8(20);
    const stateOfCharge = data.readUInt8(21);
    const mosfetStatus = data.readUInt8(22);
    const cellCount = data.readUInt8(23);
    const ntcCount = data.readUInt8(24);

    const temperatures: number[] = [];
    for (let i = 0; i < ntcCount; i++) {
      const tempRaw = data.readUInt16BE(25 + i * 2);
      const tempC = (tempRaw - 2731) / 10;
      temperatures.push(Math.round(tempC * 10) / 10);
    }

    return {
      totalVoltage,
      current,
      remainingCapacity,
      nominalCapacity,
      cycles,
      productionDate,
      balanceStatus,
      protectionStatus,
      softwareVersion,
      stateOfCharge,
      mosfetStatus,
      cellCount,
      ntcCount,
      temperatures,
    };
  }

  private parseCellVoltages(data: Buffer): number[] {
    if (data.length < 7)
      throw new Error(`Invalid cell voltages data: only ${data.length} bytes`);

    // Protocolo JBD/DP04S comando 0x04:
    // 0-1: Header (DD 04)
    // 2-3: Data length (bytes)
    // 4+: Cell voltages (2 bytes each, 0.001V)
    // -3 to -1: Checksum + end marker (77)

    const dataLength = data[3];
    const nCells = dataLength / 2;
    const cellVoltages: number[] = [];

    for (let i = 0; i < nCells; i++) {
      const voltage = data.readUInt16BE(4 + i * 2) / 1000;
      cellVoltages.push(Math.round(voltage * 1000) / 1000);
    }

    return cellVoltages;
  }
}
