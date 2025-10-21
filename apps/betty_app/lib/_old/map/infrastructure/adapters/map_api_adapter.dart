import 'dart:convert';
import '../../../shared/server/betty_api_service.dart';
import '../../domain/entities/map_location.dart';

class MapApiAdapter {
  final BettyApiService _apiService;

  const MapApiAdapter({required BettyApiService apiService}) : _apiService = apiService;

  /// Obtiene la ubicación del vehículo desde el servidor
  Future<MapLocation> getVehicleLocation() async {
    try {
      final response = await _apiService.get('/location');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // El servidor devuelve { success: true, location: { ... } }
        if (data['success'] == true && data['location'] != null) {
          final locationData = data['location'];

          final location = MapLocation(
            latitude: (locationData['latitude'] as num).toDouble(),
            longitude: (locationData['longitude'] as num).toDouble(),
            accuracy: 0.0, // El servidor no devuelve accuracy
            timestamp: DateTime.parse(locationData['timestamp'] as String),
          );
          return location;
        } else {
          throw Exception('Respuesta del servidor sin ubicación: ${data['error'] ?? "unknown"}');
        }
      } else {
        throw Exception('Error al obtener la ubicación del vehículo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener la ubicación del vehículo: $e');
    }
  }
}
