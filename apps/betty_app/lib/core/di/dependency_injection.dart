import '../config/app_config.dart';
import '../../health/health.dart';
import '../../auth/auth.dart';
import '../../shared/shared.dart';

class DependencyInjection {
  static BettyApiService? _apiService;
  static HealthRemoteDataSource? _healthRemoteDataSource;
  static AuthRemoteDataSource? _authRemoteDataSource;
  static HealthRepository? _healthRepository;
  static AuthRepository? _authRepository;
  static GetHealthDataUseCase? _getHealthDataUseCase;
  static GetProtectedDataUseCase? _getProtectedDataUseCase;

  // Services
  static BettyApiService get apiService {
    _apiService ??= BettyApiService(baseUrl: AppConfig.baseUrl);
    return _apiService!;
  }

  // Data Sources
  static HealthRemoteDataSource get healthRemoteDataSource {
    _healthRemoteDataSource ??= HealthRemoteDataSourceImpl(apiService);
    return _healthRemoteDataSource!;
  }

  static AuthRemoteDataSource get authRemoteDataSource {
    _authRemoteDataSource ??= AuthRemoteDataSourceImpl(apiService);
    return _authRemoteDataSource!;
  }

  // Repositories
  static HealthRepository get healthRepository {
    _healthRepository ??= HealthRepositoryImpl(healthRemoteDataSource);
    return _healthRepository!;
  }

  static AuthRepository get authRepository {
    _authRepository ??= AuthRepositoryImpl(authRemoteDataSource);
    return _authRepository!;
  }

  // Use Cases
  static GetHealthDataUseCase get getHealthDataUseCase {
    _getHealthDataUseCase ??= GetHealthDataUseCase(healthRepository);
    return _getHealthDataUseCase!;
  }

  static GetProtectedDataUseCase get getProtectedDataUseCase {
    _getProtectedDataUseCase ??= GetProtectedDataUseCase(authRepository);
    return _getProtectedDataUseCase!;
  }

  // Providers
  static HealthMonitorProvider createHealthMonitorProvider() {
    return HealthMonitorProvider(
      getHealthDataUseCase: getHealthDataUseCase,
      getProtectedDataUseCase: getProtectedDataUseCase,
    );
  }

  // Clean up (for testing)
  static void reset() {
    _apiService = null;
    _healthRemoteDataSource = null;
    _authRemoteDataSource = null;
    _healthRepository = null;
    _authRepository = null;
    _getHealthDataUseCase = null;
    _getProtectedDataUseCase = null;
  }
}
