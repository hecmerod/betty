import '../../infrastructure/services/trip_api_service.dart';
import '../../domain/entities/trip.dart';

class GetTripByIdUseCase {
  final TripApiService _apiService;

  const GetTripByIdUseCase(this._apiService);

  Future<Trip?> execute(String id) async {
    return await _apiService.getTripById(id);
  }
}
