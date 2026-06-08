import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static final AppConfig instance = AppConfig._();
  AppConfig._();

  String get bettyApiBaseUrl => dotenv.env['BETTY_API_BASE_URL'] ?? 'http://betty.hecmerod.online/api';

  String get bettyCameraBaseUrl => dotenv.env['BETTY_CAMERA_BASE_URL'] ?? 'http://betty-camera.hecmerod.online/camera';

  String get jwtSecret => dotenv.env['JWT_SECRET'] ?? 'undefined';
}
