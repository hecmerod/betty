import 'package:flutter/foundation.dart';
import '../../domain/entities/gps_location.dart';
import '../../domain/entities/map_type.dart';
import '../../domain/use_cases/get_current_location_use_case.dart';
import '../../domain/use_cases/stream_location_updates_use_case.dart';
import '../../domain/use_cases/toggle_map_view_use_case.dart';

class GpsProvider extends ChangeNotifier {
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  final StreamLocationUpdatesUseCase _streamLocationUpdatesUseCase;
  final ToggleMapViewUseCase _toggleMapViewUseCase;

  GpsLocation? _currentLocation;
  MapType _mapType = MapType.standard;
  bool _isLoading = false;
  String? _errorMessage;

  GpsProvider({
    required GetCurrentLocationUseCase getCurrentLocationUseCase,
    required StreamLocationUpdatesUseCase streamLocationUpdatesUseCase,
    required ToggleMapViewUseCase toggleMapViewUseCase,
  }) : _getCurrentLocationUseCase = getCurrentLocationUseCase,
       _streamLocationUpdatesUseCase = streamLocationUpdatesUseCase,
       _toggleMapViewUseCase = toggleMapViewUseCase;

  // Getters
  GpsLocation? get currentLocation => _currentLocation;
  MapType get mapType => _mapType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Obtiene la ubicación actual del usuario
  Future<void> getCurrentLocation() async {
    _setLoading(true);
    _clearError();

    try {
      _currentLocation = await _getCurrentLocationUseCase.execute();
      notifyListeners();
    } catch (e) {
      _setError('Error al obtener la ubicación: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Inicia el stream de ubicaciones en tiempo real
  void startLocationStream() {
    _clearError();

    try {
      _streamLocationUpdatesUseCase.execute().listen(
        (location) {
          _currentLocation = location;
          notifyListeners();
        },
        onError: (error) {
          _setError('Error en el stream de ubicación: $error');
        },
      );
    } catch (e) {
      _setError('Error al iniciar el stream de ubicación: $e');
    }
  }

  /// Cambia entre vista estándar y satelital
  void toggleMapView() {
    _toggleMapViewUseCase.execute();
    _mapType = _toggleMapViewUseCase.getCurrentMapType();
    notifyListeners();
  }

  /// Establece el estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Establece un mensaje de error
  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  /// Limpia el mensaje de error
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
