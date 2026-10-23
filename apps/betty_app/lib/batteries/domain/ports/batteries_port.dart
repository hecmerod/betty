import 'package:betty_app/batteries/domain/entities/battery_reading.dart';

abstract class BatteriesPort {
  Future<List<BatteryReading>> readAllBatteries();

  Future<BatteryReading> readBattery(int batteryId);

  Stream<BatteryReading> streamAllBatteries();

  Stream<BatteryReading> streamBattery(int batteryId);
}
