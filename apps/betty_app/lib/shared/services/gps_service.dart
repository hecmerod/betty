import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'permissions_service.dart';

class GpsService {
  static final GpsService instance = GpsService._();
  GpsService._();

  final _permissionsService = PermissionsService.instance;

  Future<LatLng?> getCurrentLocation() async {
    try {
      final hasPermission = await _permissionsService.requestPermission(AppPermission.location);
      if (!hasPermission) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }

  Future<bool> hasPermission() async {
    return await _permissionsService.checkPermission(AppPermission.location);
  }

  Future<bool> requestPermission() async {
    return await _permissionsService.requestPermission(AppPermission.location);
  }

  Stream<LatLng> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).map((position) => LatLng(position.latitude, position.longitude));
  }
}
