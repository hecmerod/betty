import 'package:betty_app/core/config/app_config.dart';
import 'package:betty_app/shared/services/api_service.dart';
import 'package:betty_app/shared/services/jwt_service.dart';

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
    final params = <String, String>{'type': typeQuery, if (grid) 'grid': 'true', if (index != null) 'index': '$index'};
    final query = params.entries.map((entry) => '${entry.key}=${Uri.encodeQueryComponent(entry.value)}').join('&');

    return '${_config.bettyCameraBaseUrl}/camera?$query';
  }

  Map<String, String> getVideoStreamHeaders() {
    return {'Authorization': 'Bearer ${_jwtService.generateToken()}'};
  }
}
