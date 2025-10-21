import '../../infrastructure/services/trip_api_service.dart';
import '../../domain/entities/trip.dart';

class GetCurrentTripUseCase {
  final TripApiService _apiService;

  const GetCurrentTripUseCase(this._apiService);

  Future<Trip?> execute() async {
    return await _apiService.getCurrentTrip();
  }
}
