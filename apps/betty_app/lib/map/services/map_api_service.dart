import '../models/vehicle_location.dart';
import '../../shared/services/api_service.dart';

class MapApiService {
  static final MapApiService instance = MapApiService._();
  MapApiService._();

  final _apiService = ApiService.instance;

  Future<VehicleLocation> getVehicleLocation() async {
    final response = await _apiService.get('/location');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return VehicleLocation.fromJson(await _apiService.getJson('/location', fromJson: (json) => json));
    } else {
      throw Exception('Error al obtener ubicación de la furgoneta: ${response.statusCode}');
    }
  }
}
