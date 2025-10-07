import '../config/app_config.dart';
import '../../shared/server/betty_api_service.dart';
import '../../camera/infrastructure/datasources/camera_remote_data_source.dart';
import '../../camera/infrastructure/repositories/camera_repository_impl.dart';
import '../../camera/domain/repositories/camera_repository.dart';
import '../../camera/application/usecases/get_photo.dart';
import '../../camera/application/usecases/get_video_stream.dart';
import '../../camera/presentation/providers/camera_provider.dart';
import '../../notification/infrastructure/services/notification_api_service.dart';
import '../../alarm/infrastructure/services/alarm_api_service.dart';
import '../../alarm/application/use_cases/get_alarm_status_use_case.dart';
import '../../alarm/application/use_cases/toggle_alarm_use_case.dart';
import '../../alarm/presentation/providers/alarm_provider.dart';

class DependencyInjection {
  static BettyApiService? _apiService;
  static NotificationApiService? _notificationApiService;
  static CameraRemoteDataSource? _cameraRemoteDataSource;
  static CameraRepository? _cameraRepository;
  static GetPhotoUseCase? _getPhotoUseCase;
  static GetVideoStreamUseCase? _getVideoStreamUseCase;

  // Alarm dependencies
  static AlarmApiService? _alarmApiService;
  static GetAlarmStatusUseCase? _getAlarmStatusUseCase;
  static ToggleAlarmUseCase? _toggleAlarmUseCase;

  static BettyApiService get apiService {
    _apiService ??= BettyApiService(baseUrl: AppConfig.baseUrl);
    return _apiService!;
  }

  static NotificationApiService get notificationApiService {
    _notificationApiService ??= NotificationApiService(apiService);
    return _notificationApiService!;
  }

  static CameraRemoteDataSource get cameraRemoteDataSource {
    _cameraRemoteDataSource ??= CameraRemoteDataSourceImpl(apiService);
    return _cameraRemoteDataSource!;
  }

  static CameraRepository get cameraRepository {
    _cameraRepository ??= CameraRepositoryImpl(cameraRemoteDataSource);
    return _cameraRepository!;
  }

  static GetPhotoUseCase get getPhotoUseCase {
    _getPhotoUseCase ??= GetPhotoUseCase(cameraRepository);
    return _getPhotoUseCase!;
  }

  static GetVideoStreamUseCase get getVideoStreamUseCase {
    _getVideoStreamUseCase ??= GetVideoStreamUseCase(cameraRepository);
    return _getVideoStreamUseCase!;
  }

  static CameraProvider createCameraProvider() {
    return CameraProvider(getPhotoUseCase: getPhotoUseCase, getVideoStreamUseCase: getVideoStreamUseCase);
  }

  // Alarm getters
  static AlarmApiService get alarmApiService {
    _alarmApiService ??= AlarmApiService(apiService);
    return _alarmApiService!;
  }

  static GetAlarmStatusUseCase get getAlarmStatusUseCase {
    _getAlarmStatusUseCase ??= GetAlarmStatusUseCase(alarmApiService);
    return _getAlarmStatusUseCase!;
  }

  static ToggleAlarmUseCase get toggleAlarmUseCase {
    _toggleAlarmUseCase ??= ToggleAlarmUseCase(alarmApiService);
    return _toggleAlarmUseCase!;
  }

  static AlarmProvider createAlarmProvider() {
    return AlarmProvider(getAlarmStatusUseCase, toggleAlarmUseCase);
  }

  static void reset() {
    _apiService = null;
    _notificationApiService = null;
    _cameraRemoteDataSource = null;
    _cameraRepository = null;
    _getPhotoUseCase = null;
    _getVideoStreamUseCase = null;

    // Reset alarm dependencies
    _alarmApiService = null;
    _getAlarmStatusUseCase = null;
    _toggleAlarmUseCase = null;
  }
}
