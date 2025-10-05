import '../entities/protected_data.dart';

abstract class AuthRepository {
  Future<String> generateJwtToken();
  Future<ProtectedData> getProtectedData();
}
