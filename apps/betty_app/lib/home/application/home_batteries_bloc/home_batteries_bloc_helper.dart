import 'package:betty_app/batteries/domain/entities/battery_reading.dart';

int? combinedChargePercent(List<BatteryReading> readings) {
  if (readings.isEmpty) return null;

  final nominal = readings.fold<double>(0, (sum, reading) => sum + reading.nominalCapacity);
  if (nominal <= 0) return 0;

  final remaining = readings.fold<double>(0, (sum, reading) => sum + reading.remainingCapacity);
  return ((remaining / nominal) * 100).round().clamp(0, 100);
}
