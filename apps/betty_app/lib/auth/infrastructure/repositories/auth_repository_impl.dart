import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<String> generateJwtToken() async {
    try {
      return await remoteDataSource.generateJwtToken();
    } catch (e) {
      throw Exception('Failed to generate JWT token: $e');
    }
  }
}
