import '../models/health_data_model.dart';
import '../../../shared/infrastructure/services/betty_api_service.dart';

abstract class HealthRemoteDataSource {
  Future<HealthDataModel> getHealthData();
}

class HealthRemoteDataSourceImpl implements HealthRemoteDataSource {
  final BettyApiService apiService;

  const HealthRemoteDataSourceImpl(this.apiService);

  @override
  Future<HealthDataModel> getHealthData() async {
    return await apiService.fetchHealthData();
  }
}
