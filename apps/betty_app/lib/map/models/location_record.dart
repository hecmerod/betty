import 'package:latlong2/latlong.dart';

class LocationRecord {
  final LatLng position;
  final DateTime timestamp;
  final double? altitude;

  const LocationRecord({required this.position, required this.timestamp, this.altitude});

  factory LocationRecord.fromJson(Map<String, dynamic> json) {
    return LocationRecord(
      position: LatLng((json['latitude'] as num).toDouble(), (json['longitude'] as num).toDouble()),
      timestamp: DateTime.parse(json['timestamp'] as String),
      altitude: json['altitude'] != null ? (json['altitude'] as num).toDouble() : null,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LocationRecord && other.position == position && other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(position, timestamp);
}
