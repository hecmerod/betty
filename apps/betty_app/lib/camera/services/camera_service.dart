import '../../shared/services/api_service.dart';
import '../../shared/services/jwt_service.dart';
import '../../shared/config/app_config.dart';

enum CameraType { internal, external }

class CameraService {
  static final CameraService instance = CameraService._();
  CameraService._();

  final _apiService = ApiService.instance;
  final _jwtService = JwtService.instance;
  final _config = AppConfig.instance;

  String getVideoStreamUrl({CameraType type = CameraType.internal}) {
    JwtService.instance.generateToken();
    final typeQuery = type == CameraType.internal ? 'internal' : 'external';
    return '${_config.bettyApiBaseUrl}/camera/video?type=$typeQuery';
  }

  Map<String, String> getVideoStreamHeaders() {
    return {'Authorization': 'Bearer ${_jwtService.generateToken()}'};
  }

  Future<void> capturePhoto({CameraType type = CameraType.internal}) async {
    final typeQuery = type == CameraType.internal ? 'internal' : 'external';
    await _apiService.post('/camera/photo?type=$typeQuery');
  }
}
