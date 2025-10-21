import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../config/app_config.dart';

class JwtService {
  static final JwtService instance = JwtService._();
  JwtService._();

  final _config = AppConfig.instance;

  String generateToken() {
    final jwt = JWT({'userId': 1, 'username': 'betty-user', 'deviceId': 'raspberry-pi-001'});

    return jwt.sign(SecretKey(_config.jwtSecret));
  }
}
