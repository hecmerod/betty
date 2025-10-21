import '../../infrastructure/services/trip_api_service.dart';

class HasTripInProgressUseCase {
  final TripApiService _apiService;

  const HasTripInProgressUseCase(this._apiService);

  Future<bool> execute() async {
    return await _apiService.hasTripInProgress();
  }
}
