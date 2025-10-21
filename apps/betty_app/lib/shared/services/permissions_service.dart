import 'package:geolocator/geolocator.dart';

enum AppPermission { location }

class PermissionsService {
  static final PermissionsService instance = PermissionsService._();
  PermissionsService._();

  Future<bool> checkPermission(AppPermission permission) async {
    switch (permission) {
      case AppPermission.location:
        final status = await Geolocator.checkPermission();
        return status == LocationPermission.always || status == LocationPermission.whileInUse;
    }
  }

  Future<bool> requestPermission(AppPermission permission) async {
    switch (permission) {
      case AppPermission.location:
        final status = await Geolocator.checkPermission();
        if (status == LocationPermission.denied) {
          final newStatus = await Geolocator.requestPermission();
          return newStatus == LocationPermission.always || newStatus == LocationPermission.whileInUse;
        }
        return status == LocationPermission.always || status == LocationPermission.whileInUse;
    }
  }

  Future<bool> isPermissionDeniedForever(AppPermission permission) async {
    switch (permission) {
      case AppPermission.location:
        final status = await Geolocator.checkPermission();
        return status == LocationPermission.deniedForever;
    }
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<Map<AppPermission, bool>> checkAllPermissions() async {
    return {AppPermission.location: await checkPermission(AppPermission.location)};
  }

  Future<Map<AppPermission, bool>> requestAllPermissions() async {
    return {AppPermission.location: await requestPermission(AppPermission.location)};
  }
}
