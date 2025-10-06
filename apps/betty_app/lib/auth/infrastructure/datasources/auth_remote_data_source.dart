import '../../../shared/infrastructure/services/betty_api_service.dart';
import '../services/jwt_service.dart';

abstract class AuthRemoteDataSource {
  Future<String> generateJwtToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final BettyApiService apiService;

  const AuthRemoteDataSourceImpl(this.apiService);

  @override
  Future<String> generateJwtToken() async {
    return JwtService.generateToken();
  }
}
