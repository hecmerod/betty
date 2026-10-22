import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static final AppConfig instance = AppConfig._();
  AppConfig._();

  String get bettyApiBaseUrl => dotenv.env['BETTY_API_BASE_URL'] ?? 'http://fragoneta.app/api';

  String get bettyCameraBaseUrl {
    final configured = dotenv.env['BETTY_CAMERA_BASE_URL'] ?? 'http://camera.fragoneta.app';
    var base = configured.replaceAll(RegExp(r'/+$'), '');
    const cameraPath = '/camera';
    if (base.endsWith(cameraPath)) {
      base = base.substring(0, base.length - cameraPath.length);
    }
    return base;
  }

  String get jwtSecret => dotenv.env['JWT_SECRET'] ?? 'undefined';

  String get appLogo => dotenv.env['APP_LOGO'] ?? 'assets/betty-icon.png';

  String get mapBoxApiKey => dotenv.env['MAP_BOX_API_KEY'] ?? '';
}
