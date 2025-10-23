import '../../shared/services/api_service.dart';
import '../../shared/services/jwt_service.dart';
import '../../shared/config/app_config.dart';

class CameraService {
  static final CameraService instance = CameraService._();
  CameraService._();

  final _apiService = ApiService.instance;
  final _jwtService = JwtService.instance;
  final _config = AppConfig.instance;

  String getVideoStreamUrl() {
    JwtService.instance.generateToken();
    return '${_config.bettyApiBaseUrl}/camera/video';
  }

  Map<String, String> getVideoStreamHeaders() {
    return {'Authorization': 'Bearer ${_jwtService.generateToken()}'};
  }

  Future<void> capturePhoto() async {
    await _apiService.post('/camera/photo');
  }
}
