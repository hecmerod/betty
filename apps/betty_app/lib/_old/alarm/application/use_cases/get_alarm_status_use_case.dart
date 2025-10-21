import '../../domain/entities/alarm_status.dart';
import '../../infrastructure/services/alarm_api_service.dart';

class GetAlarmStatusUseCase {
  final AlarmApiService _apiService;

  GetAlarmStatusUseCase(this._apiService);

  Future<AlarmStatus> execute() async {
    return await _apiService.getStatus();
  }
}
