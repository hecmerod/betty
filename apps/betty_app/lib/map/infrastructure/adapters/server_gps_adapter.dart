import 'dart:convert';

import 'package:betty_app/map/domain/entities/map_location.dart';
import 'package:betty_app/map/domain/ports/server_gps_port.dart';
import 'package:betty_app/shared/services/api_service.dart';

class ServerGpsAdapter implements ServerGpsPort {
  ServerGpsAdapter({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  @override
  Future<MapLocation> getCurrentLocation() async {
    final live = await _readLiveLocation();
    if (live != null) return live;

    final stored = await _readLastStoredLocation();
    if (stored != null) return stored;

    throw Exception('Error al obtener el GPS');
  }

  Future<MapLocation?> _readLiveLocation() async {
    final response = await _apiService.get('/location');

    if (response.statusCode != 200) {
      throw Exception('Error al obtener el GPS');
    }

    try {
      final data = json.decode(response.body);
      if (data is! Map<String, dynamic>) {
        throw Exception('Error al obtener el GPS');
      }

      if (data['success'] != true) return null;

      final location = data['location'];
      if (location is! Map<String, dynamic>) return null;

      return _mapLocationFromJson(location);
    } on FormatException {
      throw Exception('Error al obtener el GPS');
    }
  }

  Future<MapLocation?> _readLastStoredLocation() async {
    final response = await _apiService.get('/locations');

    if (response.statusCode != 200) return null;

    try {
      final data = json.decode(response.body);
      if (data is! Map<String, dynamic>) return null;

      final locations = data['locations'];
      if (locations is! List || locations.isEmpty) return null;

      final first = locations.first;
      if (first is! Map<String, dynamic>) return null;

      return _mapLocationFromJson(first);
    } on FormatException {
      return null;
    }
  }
}

MapLocation _mapLocationFromJson(Map<String, dynamic> json) {
  return MapLocation(
    latitude: _asDouble(json['latitude']),
    longitude: _asDouble(json['longitude']),
    altitude: _asOptionalDouble(json['altitude']),
    timestamp: _asDateTime(json['timestamp']),
  );
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  throw const FormatException('Valor numérico inválido');
}

double? _asOptionalDouble(Object? value) {
  if (value == null) return null;
  return _asDouble(value);
}

DateTime _asDateTime(Object? value) {
  if (value is String) return DateTime.parse(value);
  throw const FormatException('Fecha inválida');
}
