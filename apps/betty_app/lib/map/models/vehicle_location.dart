import 'package:latlong2/latlong.dart';

class VehicleLocation {
  final LatLng position;
  final DateTime timestamp;
  final double? accuracy;

  VehicleLocation({required this.position, required this.timestamp, this.accuracy});

  factory VehicleLocation.fromJson(Map<String, dynamic> json) {
    final locationData = json['location'] ?? json;

    return VehicleLocation(
      position: LatLng((locationData['latitude'] as num).toDouble(), (locationData['longitude'] as num).toDouble()),
      timestamp: DateTime.parse(locationData['timestamp'] ?? DateTime.now().toIso8601String()),
      accuracy: locationData['accuracy'] != null ? (locationData['accuracy'] as num).toDouble() : null,
    );
  }
}
