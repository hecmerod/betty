import 'dart:convert';
import '../../shared/services/api_service.dart';
import '../models/sensor.dart';

class SensorService {
  static final SensorService instance = SensorService._();
  SensorService._();

  final _apiService = ApiService.instance;

  Future<List<Sensor>> getSensorsStatus() async {
    final response = await _apiService.get('/sensors');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> sensorsData = responseData['sensors'] ?? [];
      return sensorsData.map((json) => Sensor.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Error al obtener el estado de los sensores');
    }
  }

  Future<void> enableSensor(SensorType sensorType) async {
    final response = await _apiService.patch('/sensors/${sensorType.id}/enable');

    if (response.statusCode != 200) {
      throw Exception('Error al activar el sensor ${sensorType.displayName}');
    }
  }

  Future<void> disableSensor(SensorType sensorType) async {
    final response = await _apiService.patch('/sensors/${sensorType.id}/disable');

    if (response.statusCode != 200) {
      throw Exception('Error al desactivar el sensor ${sensorType.displayName}');
    }
  }

  Future<void> toggleSensor(SensorType sensorType, bool currentStatus) async {
    if (currentStatus) {
      await disableSensor(sensorType);
    } else {
      await enableSensor(sensorType);
    }
  }
}
