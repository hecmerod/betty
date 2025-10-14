import 'package:flutter/foundation.dart';
import '../../domain/entities/trip.dart';
import '../../application/use_cases/get_all_trips_use_case.dart';
import '../../application/use_cases/get_current_trip_use_case.dart';
import '../../application/use_cases/has_trip_in_progress_use_case.dart';
import '../../application/use_cases/get_trip_by_id_use_case.dart';
import '../../application/use_cases/create_trip_use_case.dart';
import '../../application/use_cases/end_trip_use_case.dart';

class TripProvider with ChangeNotifier {
  final GetAllTripsUseCase _getAllTripsUseCase;
  final GetCurrentTripUseCase _getCurrentTripUseCase;
  final HasTripInProgressUseCase _hasTripInProgressUseCase;
  final GetTripByIdUseCase _getTripByIdUseCase;
  final CreateTripUseCase _createTripUseCase;
  final EndTripUseCase _endTripUseCase;

  TripProvider({
    required GetAllTripsUseCase getAllTripsUseCase,
    required GetCurrentTripUseCase getCurrentTripUseCase,
    required HasTripInProgressUseCase hasTripInProgressUseCase,
    required GetTripByIdUseCase getTripByIdUseCase,
    required CreateTripUseCase createTripUseCase,
    required EndTripUseCase endTripUseCase,
  }) : _getAllTripsUseCase = getAllTripsUseCase,
       _getCurrentTripUseCase = getCurrentTripUseCase,
       _hasTripInProgressUseCase = hasTripInProgressUseCase,
       _getTripByIdUseCase = getTripByIdUseCase,
       _createTripUseCase = createTripUseCase,
       _endTripUseCase = endTripUseCase;

  List<Trip> _trips = [];
  Trip? _currentTrip;
  bool _hasTripInProgress = false;
  bool _isLoading = false;
  String? _error;

  List<Trip> get trips => _trips;
  Trip? get currentTrip => _currentTrip;
  bool get hasTripInProgress => _hasTripInProgress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllTrips() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _trips = await _getAllTripsUseCase.execute();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _trips = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCurrentTrip() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentTrip = await _getCurrentTripUseCase.execute();
      _hasTripInProgress = _currentTrip != null;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentTrip = null;
      _hasTripInProgress = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkTripInProgress() async {
    try {
      _hasTripInProgress = await _hasTripInProgressUseCase.execute();
      // No llamar notifyListeners aquí para evitar rebuild durante build
    } catch (e) {
      _hasTripInProgress = false;
    }
  }

  Future<Trip?> getTripById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final trip = await _getTripByIdUseCase.execute(id);
      _error = null;
      return trip;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Trip?> createTrip(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final trip = await _createTripUseCase.execute(name);
      _currentTrip = trip;
      _hasTripInProgress = true;
      _error = null;

      // Recargar lista de trips
      await loadAllTrips();

      return trip;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Trip?> endTrip(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final trip = await _endTripUseCase.execute(id);
      _currentTrip = null;
      _hasTripInProgress = false;
      _error = null;

      // Recargar lista de trips
      await loadAllTrips();

      return trip;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Método optimizado para inicializar el estado de trips
  /// Reduce las notificaciones a una sola al final
  Future<void> initializeTripsState() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Verificar si hay trip en progreso
      _hasTripInProgress = await _hasTripInProgressUseCase.execute();

      if (_hasTripInProgress) {
        // Cargar el trip actual
        _currentTrip = await _getCurrentTripUseCase.execute();
      } else {
        // Cargar todos los trips
        _trips = await _getAllTripsUseCase.execute();
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      _hasTripInProgress = false;
      _currentTrip = null;
      _trips = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
