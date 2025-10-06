import '../config/app_config.dart';
import '../../auth/auth.dart';
import '../../shared/shared.dart';
import '../../camera/camera.dart';

class DependencyInjection {
  static BettyApiService? _apiService;
  static AuthRemoteDataSource? _authRemoteDataSource;
  static CameraRemoteDataSource? _cameraRemoteDataSource;
  static AuthRepository? _authRepository;
  static CameraRepository? _cameraRepository;
  static GetPhotoUseCase? _getPhotoUseCase;
  static GetVideoStreamUseCase? _getVideoStreamUseCase;

  static BettyApiService get apiService {
    _apiService ??= BettyApiService(baseUrl: AppConfig.baseUrl);
    return _apiService!;
  }

  static AuthRemoteDataSource get authRemoteDataSource {
    _authRemoteDataSource ??= AuthRemoteDataSourceImpl(apiService);
    return _authRemoteDataSource!;
  }

  static CameraRemoteDataSource get cameraRemoteDataSource {
    _cameraRemoteDataSource ??= CameraRemoteDataSourceImpl(apiService);
    return _cameraRemoteDataSource!;
  }

  static AuthRepository get authRepository {
    _authRepository ??= AuthRepositoryImpl(authRemoteDataSource);
    return _authRepository!;
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
    _authRemoteDataSource = null;
    _cameraRemoteDataSource = null;
    _authRepository = null;
    _cameraRepository = null;
    _getPhotoUseCase = null;
    _getVideoStreamUseCase = null;
  }
}
