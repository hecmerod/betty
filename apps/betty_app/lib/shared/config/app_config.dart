import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static final AppConfig instance = AppConfig._();
  AppConfig._();

  String get bettyServerHost => dotenv.env['BETTY_SERVER_HOST'] ?? 'twee-importantly-omar.ngrok-free.dev';

  String get bettyServerPort => dotenv.env['BETTY_SERVER_PORT'] ?? '443';

  String get bettyApiBaseUrl => dotenv.env['BETTY_API_BASE_URL'] ?? 'https://twee-importantly-omar.ngrok-free.dev/api';

  String get jwtSecret => dotenv.env['JWT_SECRET'] ?? 'betty-secret-key-2024-fallback';

  String get jwtExpiresIn => dotenv.env['JWT_EXPIRES_IN'] ?? '24h';
}
