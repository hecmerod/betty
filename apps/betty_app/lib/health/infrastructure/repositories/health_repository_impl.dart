import '../../domain/entities/health_data.dart';
import '../../domain/repositories/health_repository.dart';
import '../datasources/health_remote_data_source.dart';

class HealthRepositoryImpl implements HealthRepository {
  final HealthRemoteDataSource remoteDataSource;

  const HealthRepositoryImpl(this.remoteDataSource);

  @override
  Future<HealthData> getHealthData() async {
    try {
      final healthDataModel = await remoteDataSource.getHealthData();
      return healthDataModel.toEntity();
    } catch (e) {
      throw Exception('Failed to get health data: $e');
    }
  }
}
