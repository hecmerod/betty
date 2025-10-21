import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl => dotenv.env['BETTY_API_BASE_URL'] ?? 'http://192.168.1.232:3000/api';

  static String get jwtSecret => dotenv.env['JWT_SECRET'] ?? 'betty-secret-key-2024-fallback';

  static String get jwtExpiresIn => dotenv.env['JWT_EXPIRES_IN'] ?? '24h';

  static String get serverHost => dotenv.env['BETTY_SERVER_HOST'] ?? 'localhost';

  static String get serverPort => dotenv.env['BETTY_SERVER_PORT'] ?? '3000';
}
