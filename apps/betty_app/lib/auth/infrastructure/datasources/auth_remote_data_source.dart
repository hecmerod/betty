import '../models/protected_data_model.dart';
import '../../../shared/infrastructure/services/betty_api_service.dart';
import '../services/jwt_service.dart';

abstract class AuthRemoteDataSource {
  Future<String> generateJwtToken();
  Future<ProtectedDataModel> getProtectedData();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final BettyApiService apiService;

  const AuthRemoteDataSourceImpl(this.apiService);

  @override
  Future<String> generateJwtToken() async {
    return JwtService.generateToken();
  }

  @override
  Future<ProtectedDataModel> getProtectedData() async {
    final token = await generateJwtToken();
    final data = await apiService.fetchProtectedData(token);
    return ProtectedDataModel.fromJson(data);
  }
}
