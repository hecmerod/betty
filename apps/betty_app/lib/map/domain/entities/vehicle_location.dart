import 'map_location.dart';

class VehicleLocation {
  final MapLocation location;
  final DateTime lastUpdate;

  const VehicleLocation({required this.location, required this.lastUpdate});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleLocation &&
          runtimeType == other.runtimeType &&
          location == other.location &&
          lastUpdate == other.lastUpdate;

  @override
  int get hashCode => location.hashCode ^ lastUpdate.hashCode;

  @override
  String toString() {
    return 'VehicleLocation(location: $location, lastUpdate: $lastUpdate)';
  }
}
