import '../../domain/entities/alarm_status.dart';
import '../../infrastructure/services/alarm_api_service.dart';

class ToggleAlarmUseCase {
  final AlarmApiService _apiService;

  ToggleAlarmUseCase(this._apiService);

  Future<AlarmStatus> execute(bool activate) async {
    if (activate) {
      return await _apiService.activate();
    } else {
      return await _apiService.deactivate();
    }
  }
}
