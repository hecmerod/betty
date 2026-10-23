import 'package:betty_app/map/domain/entities/map_location.dart';
import 'package:betty_app/map/domain/ports/device_location_port.dart';
import 'package:betty_app/shared/services/gps_service.dart';

class DeviceLocationAdapter implements DeviceLocationPort {
  DeviceLocationAdapter({GpsService? gpsService})
    : _gpsService = gpsService ?? GpsService.instance;

  final GpsService _gpsService;

  @override
  Future<MapLocation?> getCurrentLocation() async {
    final position = await _gpsService.getCurrentLocation();
    if (position == null) return null;

    return MapLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
    );
  }

  @override
  Stream<MapLocation> watchLocation() {
    return _gpsService.getLocationStream().map(
      (position) => MapLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      ),
    );
  }
}
