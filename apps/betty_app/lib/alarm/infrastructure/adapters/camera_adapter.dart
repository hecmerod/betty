import 'package:betty_app/alarm/domain/camera_type.dart';
import 'package:betty_app/alarm/domain/ports/camera_port.dart';
import 'package:betty_app/core/config/app_config.dart';
import 'package:betty_app/shared/services/jwt_service.dart';

class CameraAdapter implements CameraPort {
  CameraAdapter({required AppConfig config, required JwtService jwtService})
    : _config = config,
      _jwtService = jwtService;

  final AppConfig _config;
  final JwtService _jwtService;

  @override
  String getVideoStreamUrl({CameraType type = CameraType.internal, int? index, bool grid = false}) {
    _jwtService.generateToken();
    final typeQuery = type == CameraType.internal ? 'internal' : 'external';
    final params = <String, String>{'type': typeQuery, if (grid) 'grid': 'true', if (index != null) 'index': '$index'};
    final query = params.entries.map((entry) => '${entry.key}=${Uri.encodeQueryComponent(entry.value)}').join('&');

    return '${_config.bettyCameraBaseUrl}/camera?$query';
  }

  @override
  Map<String, String> getVideoStreamHeaders() {
    return {'Authorization': 'Bearer ${_jwtService.generateToken()}'};
  }
}
