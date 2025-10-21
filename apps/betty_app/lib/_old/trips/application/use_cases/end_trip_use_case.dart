import '../../infrastructure/services/trip_api_service.dart';
import '../../domain/entities/trip.dart';

class EndTripUseCase {
  final TripApiService _apiService;

  const EndTripUseCase(this._apiService);

  Future<Trip> execute(String id) async {
    return await _apiService.endTrip(id);
  }
}
