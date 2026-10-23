import 'package:equatable/equatable.dart';

class BatteryReading extends Equatable {
  final String deviceAddress;
  final int batteryId;
  final double totalVoltage;
  final double current;
  final double remainingCapacity;
  final double nominalCapacity;
  final int cycles;
  final String productionDate;
  final List<int> balanceStatus;
  final int protectionStatus;
  final int softwareVersion;
  final int stateOfCharge;
  final int mosfetStatus;
  final int cellCount;
  final int ntcCount;
  final List<double> temperatures;
  final List<double> cellVoltages;
  final double averageCellVoltage;
  final double minCellVoltage;
  final double maxCellVoltage;
  final double voltageDifference;
  final double averageTemperature;
  final bool isBalanced;
  final bool isCharging;
  final bool isDischarging;
  final DateTime timestamp;

  const BatteryReading({
    required this.deviceAddress,
    required this.batteryId,
    required this.totalVoltage,
    required this.current,
    required this.remainingCapacity,
    required this.nominalCapacity,
    required this.cycles,
    required this.productionDate,
    required this.balanceStatus,
    required this.protectionStatus,
    required this.softwareVersion,
    required this.stateOfCharge,
    required this.mosfetStatus,
    required this.cellCount,
    required this.ntcCount,
    required this.temperatures,
    required this.cellVoltages,
    required this.averageCellVoltage,
    required this.minCellVoltage,
    required this.maxCellVoltage,
    required this.voltageDifference,
    required this.averageTemperature,
    required this.isBalanced,
    required this.isCharging,
    required this.isDischarging,
    required this.timestamp,
  });

  BatteryReading copyWith({
    String? deviceAddress,
    int? batteryId,
    double? totalVoltage,
    double? current,
    double? remainingCapacity,
    double? nominalCapacity,
    int? cycles,
    String? productionDate,
    List<int>? balanceStatus,
    int? protectionStatus,
    int? softwareVersion,
    int? stateOfCharge,
    int? mosfetStatus,
    int? cellCount,
    int? ntcCount,
    List<double>? temperatures,
    List<double>? cellVoltages,
    double? averageCellVoltage,
    double? minCellVoltage,
    double? maxCellVoltage,
    double? voltageDifference,
    double? averageTemperature,
    bool? isBalanced,
    bool? isCharging,
    bool? isDischarging,
    DateTime? timestamp,
  }) {
    return BatteryReading(
      deviceAddress: deviceAddress ?? this.deviceAddress,
      batteryId: batteryId ?? this.batteryId,
      totalVoltage: totalVoltage ?? this.totalVoltage,
      current: current ?? this.current,
      remainingCapacity: remainingCapacity ?? this.remainingCapacity,
      nominalCapacity: nominalCapacity ?? this.nominalCapacity,
      cycles: cycles ?? this.cycles,
      productionDate: productionDate ?? this.productionDate,
      balanceStatus: balanceStatus ?? this.balanceStatus,
      protectionStatus: protectionStatus ?? this.protectionStatus,
      softwareVersion: softwareVersion ?? this.softwareVersion,
      stateOfCharge: stateOfCharge ?? this.stateOfCharge,
      mosfetStatus: mosfetStatus ?? this.mosfetStatus,
      cellCount: cellCount ?? this.cellCount,
      ntcCount: ntcCount ?? this.ntcCount,
      temperatures: temperatures ?? this.temperatures,
      cellVoltages: cellVoltages ?? this.cellVoltages,
      averageCellVoltage: averageCellVoltage ?? this.averageCellVoltage,
      minCellVoltage: minCellVoltage ?? this.minCellVoltage,
      maxCellVoltage: maxCellVoltage ?? this.maxCellVoltage,
      voltageDifference: voltageDifference ?? this.voltageDifference,
      averageTemperature: averageTemperature ?? this.averageTemperature,
      isBalanced: isBalanced ?? this.isBalanced,
      isCharging: isCharging ?? this.isCharging,
      isDischarging: isDischarging ?? this.isDischarging,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
    deviceAddress,
    batteryId,
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
    cellVoltages,
    averageCellVoltage,
    minCellVoltage,
    maxCellVoltage,
    voltageDifference,
    averageTemperature,
    isBalanced,
    isCharging,
    isDischarging,
    timestamp,
  ];
}
