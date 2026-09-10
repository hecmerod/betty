import '../models/location_record.dart';
import '../models/vehicle_location.dart';
import '../../shared/services/api_service.dart';

class MapApiService {
  static const pageSize = 10;

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

  Future<List<LocationRecord>> getLocations({required DateTime from, required DateTime to, int page = 1}) {
    return _apiService.getJson(
      '/locations',
      queryParameters: {
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
        'page': page.toString(),
      },
      fromJson: (json) {
        final locations = json['locations'] as List<dynamic>? ?? [];
        return locations.map((item) => LocationRecord.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }

  Future<List<LocationRecord>> getAllLocations({required DateTime from, required DateTime to}) async {
    final locations = <LocationRecord>[];
    var page = 1;

    while (true) {
      final batch = await getLocations(from: from, to: to, page: page);
      locations.addAll(batch);

      if (batch.length < pageSize || page >= 100) break;
      page++;
    }

    return locations;
  }
}
