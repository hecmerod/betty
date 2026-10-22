import 'dart:convert';

import 'package:betty_app/alarm/domain/ports/sensor_port.dart';
import 'package:betty_app/alarm/domain/sensor.dart';
import 'package:betty_app/shared/services/api_service.dart';

class SensorAdapter implements SensorPort {
  SensorAdapter({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  @override
  Future<List<Sensor>> getSensorsStatus() async {
    final response = await _apiService.get('/sensors');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> sensorsData = responseData['sensors'] ?? [];
      return sensorsData
          .map((json) => Sensor.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Error al obtener el estado de los sensores');
    }
  }

  @override
  Future<void> enableSensor(SensorType sensorType) async {
    final response = await _apiService.patch(
      '/sensors/${sensorType.id}/enable',
    );

    if (response.statusCode != 200) {
      throw Exception('Error al activar el sensor ${sensorType.displayName}');
    }
  }

  @override
  Future<void> disableSensor(SensorType sensorType) async {
    final response = await _apiService.patch(
      '/sensors/${sensorType.id}/disable',
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al desactivar el sensor ${sensorType.displayName}',
      );
    }
  }

  @override
  Future<void> toggleSensor(SensorType sensorType, bool currentStatus) async {
    if (currentStatus) {
      await disableSensor(sensorType);
    } else {
      await enableSensor(sensorType);
    }
  }
}
