import '../config/app_config.dart';
import '../../shared/shared.dart';
import '../../camera/camera.dart';
import '../../notification/notification.dart';

class DependencyInjection {
  static BettyApiService? _apiService;
  static NotificationApiService? _notificationApiService;
  static CameraRemoteDataSource? _cameraRemoteDataSource;
  static CameraRepository? _cameraRepository;
  static GetPhotoUseCase? _getPhotoUseCase;
  static GetVideoStreamUseCase? _getVideoStreamUseCase;

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

  static void reset() {
    _apiService = null;
    _notificationApiService = null;
    _cameraRemoteDataSource = null;
    _cameraRepository = null;
    _getPhotoUseCase = null;
    _getVideoStreamUseCase = null;
  }
}
