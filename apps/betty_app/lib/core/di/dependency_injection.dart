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
import '../../trips/infrastructure/services/trip_api_service.dart';
import '../../trips/application/use_cases/get_all_trips_use_case.dart';
import '../../trips/application/use_cases/get_current_trip_use_case.dart';
import '../../trips/application/use_cases/has_trip_in_progress_use_case.dart';
import '../../trips/application/use_cases/get_trip_by_id_use_case.dart';
import '../../trips/application/use_cases/create_trip_use_case.dart';
import '../../trips/application/use_cases/end_trip_use_case.dart';
import '../../trips/presentation/providers/trip_provider.dart';

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

  // Trip dependencies
  static TripApiService? _tripApiService;
  static GetAllTripsUseCase? _getAllTripsUseCase;
  static GetCurrentTripUseCase? _getCurrentTripUseCase;
  static HasTripInProgressUseCase? _hasTripInProgressUseCase;
  static GetTripByIdUseCase? _getTripByIdUseCase;
  static CreateTripUseCase? _createTripUseCase;
  static EndTripUseCase? _endTripUseCase;

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

  // Trip getters
  static TripApiService get tripApiService {
    _tripApiService ??= TripApiService(apiService);
    return _tripApiService!;
  }

  static GetAllTripsUseCase get getAllTripsUseCase {
    _getAllTripsUseCase ??= GetAllTripsUseCase(tripApiService);
    return _getAllTripsUseCase!;
  }

  static GetCurrentTripUseCase get getCurrentTripUseCase {
    _getCurrentTripUseCase ??= GetCurrentTripUseCase(tripApiService);
    return _getCurrentTripUseCase!;
  }

  static HasTripInProgressUseCase get hasTripInProgressUseCase {
    _hasTripInProgressUseCase ??= HasTripInProgressUseCase(tripApiService);
    return _hasTripInProgressUseCase!;
  }

  static GetTripByIdUseCase get getTripByIdUseCase {
    _getTripByIdUseCase ??= GetTripByIdUseCase(tripApiService);
    return _getTripByIdUseCase!;
  }

  static CreateTripUseCase get createTripUseCase {
    _createTripUseCase ??= CreateTripUseCase(tripApiService);
    return _createTripUseCase!;
  }

  static EndTripUseCase get endTripUseCase {
    _endTripUseCase ??= EndTripUseCase(tripApiService);
    return _endTripUseCase!;
  }

  static TripProvider createTripProvider() {
    return TripProvider(
      getAllTripsUseCase: getAllTripsUseCase,
      getCurrentTripUseCase: getCurrentTripUseCase,
      hasTripInProgressUseCase: hasTripInProgressUseCase,
      getTripByIdUseCase: getTripByIdUseCase,
      createTripUseCase: createTripUseCase,
      endTripUseCase: endTripUseCase,
    );
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

    // Reset trip dependencies
    _tripApiService = null;
    _getAllTripsUseCase = null;
    _getCurrentTripUseCase = null;
    _hasTripInProgressUseCase = null;
    _getTripByIdUseCase = null;
    _createTripUseCase = null;
    _endTripUseCase = null;
  }
}
