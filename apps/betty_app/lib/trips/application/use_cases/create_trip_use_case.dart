import '../../infrastructure/services/trip_api_service.dart';
import '../../domain/entities/trip.dart';

class CreateTripUseCase {
  final TripApiService _apiService;

  const CreateTripUseCase(this._apiService);

  Future<Trip> execute(String name) async {
    return await _apiService.createTrip(name);
  }
}
