import '../../domain/entities/protected_data.dart';
import '../../domain/repositories/auth_repository.dart';

class GetProtectedDataUseCase {
  final AuthRepository repository;

  const GetProtectedDataUseCase(this.repository);

  Future<ProtectedData> call() async {
    return await repository.getProtectedData();
  }
}
