import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class JwtService {
  static String generateToken() {
    final jwtSecret =
        dotenv.env['JWT_SECRET'] ?? 'betty-secret-key-2024-fallback';

    final jwt = JWT({
      'userId': 1,
      'username': 'betty-user',
      'deviceId': 'raspberry-pi-001',
    });

    return jwt.sign(SecretKey(jwtSecret));
  }
}
