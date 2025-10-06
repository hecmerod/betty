import '../entities/gps_location.dart';
import '../entities/map_type.dart';

abstract interface class IGpsRepository {
  /// Obtiene la ubicación actual del dispositivo
  Future<GpsLocation> getCurrentLocation();

  /// Stream de ubicaciones en tiempo real
  Stream<GpsLocation> getLocationStream();

  /// Verifica si los permisos de ubicación están concedidos
  Future<bool> hasLocationPermission();

  /// Solicita permisos de ubicación
  Future<bool> requestLocationPermission();

  /// Verifica si el servicio de ubicación está habilitado
  Future<bool> isLocationServiceEnabled();

  /// Cambia el tipo de mapa (estándar/satélite)
  void setMapType(MapType mapType);

  /// Obtiene el tipo de mapa actual
  MapType getMapType();
}
