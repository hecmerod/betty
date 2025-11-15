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

  String getVideoStreamUrl({CameraType type = CameraType.internal, int? index, bool grid = false}) {
    JwtService.instance.generateToken();
    final typeQuery = type == CameraType.internal ? 'internal' : 'external';
    var url = '${_config.bettyApiBaseUrl}/camera/video?type=$typeQuery';

    if (grid) {
      url += '&grid=true';
    }

    if (index != null) {
      url += '&index=$index';
    }

    return url;
  }

  Map<String, String> getVideoStreamHeaders() {
    return {'Authorization': 'Bearer ${_jwtService.generateToken()}'};
  }

  Future<void> capturePhoto({CameraType type = CameraType.internal, int? index}) async {
    final typeQuery = type == CameraType.internal ? 'internal' : 'external';
    var url = '/camera/photo?type=$typeQuery';

    if (index != null) {
      url += '&index=$index';
    }

    await _apiService.post(url);
  }
}
