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

  Future<List<LocationRecord>> getLocations({DateTime? from, DateTime? to, int page = 1}) {
    final queryParameters = <String, String>{};

    if (from != null) queryParameters['from'] = _toIso8601(from);
    if (to != null) queryParameters['to'] = _toIso8601(to);
    if (from != null || to != null) queryParameters['page'] = page.toString();

    return _apiService.getJson(
      '/locations',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
      fromJson: (json) {
        final locations = json['locations'] as List<dynamic>? ?? [];
        return locations.map((item) => LocationRecord.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }

  Future<List<LocationRecord>> getAllLocations({DateTime? from, DateTime? to}) async {
    final hasRange = from != null || to != null;

    if (!hasRange) {
      return _sortedNewestFirst(await getLocations());
    }

    final locations = <LocationRecord>[];
    var page = 1;

    while (true) {
      final batch = await getLocations(from: from, to: to, page: page);
      locations.addAll(batch);

      if (batch.length < pageSize || page >= 100) break;
      page++;
    }

    return _sortedNewestFirst(locations);
  }

  List<LocationRecord> _sortedNewestFirst(List<LocationRecord> locations) {
    return [...locations]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// NestJS `@IsDateString()` rejects Dart's 6-digit microsecond ISO strings.
  String _toIso8601(DateTime dateTime) {
    final utc = dateTime.toUtc();
    return DateTime.utc(
      utc.year,
      utc.month,
      utc.day,
      utc.hour,
      utc.minute,
      utc.second,
      utc.millisecond,
    ).toIso8601String();
  }
}
