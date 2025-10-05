import '../../domain/entities/health_data.dart';
import '../../domain/repositories/health_repository.dart';

class GetHealthDataUseCase {
  final HealthRepository repository;

  const GetHealthDataUseCase(this.repository);

  Future<HealthData> call() async {
    return await repository.getHealthData();
  }
}
