import '../entities/health_data.dart';

abstract class HealthRepository {
  Future<HealthData> getHealthData();
}
