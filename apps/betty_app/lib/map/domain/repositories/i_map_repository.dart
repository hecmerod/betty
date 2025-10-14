import '../entities/map_location.dart';
import '../entities/map_type.dart';

abstract interface class IMapRepository {
  /// Obtiene la ubicación actual del dispositivo
  Future<MapLocation> getCurrentLocation();

  /// Stream de ubicaciones en tiempo real
  Stream<MapLocation> getLocationStream();

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
