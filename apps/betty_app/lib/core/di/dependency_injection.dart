import '../config/app_config.dart';
import '../../shared/shared.dart';
import '../../camera/camera.dart';
import '../../notification/notification.dart';
import '../../alarm/alarm.dart';

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
