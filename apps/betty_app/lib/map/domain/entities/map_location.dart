import 'package:equatable/equatable.dart';

class MapLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double? altitude;
  final DateTime timestamp;

  const MapLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.altitude,
  });

  @override
  List<Object?> get props => [latitude, longitude, altitude, timestamp];
}
