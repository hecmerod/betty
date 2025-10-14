import '../../infrastructure/services/trip_api_service.dart';
import '../../domain/entities/trip.dart';

class GetAllTripsUseCase {
  final TripApiService _apiService;

  const GetAllTripsUseCase(this._apiService);

  Future<List<Trip>> execute() async {
    return await _apiService.getAllTrips();
  }
}
