import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeConfig {
  static final HomeConfig instance = HomeConfig._();
  HomeConfig._();

  String get threeDVanModel => dotenv.env['THREE_D_VAN_MODEL'] ?? 'assets/models/van.glb';
}
