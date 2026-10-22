import 'package:betty_app/alarm/domain/sensor.dart';

abstract class SensorPort {
  Future<List<Sensor>> getSensorsStatus();

  Future<void> enableSensor(SensorType sensorType);

  Future<void> disableSensor(SensorType sensorType);

  Future<void> toggleSensor(SensorType sensorType, bool currentStatus);
}
