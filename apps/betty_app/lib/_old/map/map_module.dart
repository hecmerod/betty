import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../shared/server/betty_api_service.dart';
import 'domain/repositories/i_map_repository.dart';
import 'domain/use_cases/get_current_location_use_case.dart';
import 'domain/use_cases/get_vehicle_location_use_case.dart';
import 'domain/use_cases/stream_location_updates_use_case.dart';
import 'domain/use_cases/toggle_map_view_use_case.dart';
import 'infrastructure/adapters/map_api_adapter.dart';
import 'infrastructure/repositories/map_repository_impl.dart';
import 'presentation/providers/map_provider.dart';

class MapModule {
  static List<SingleChildWidget> get providers => [
    // API Service
    Provider<BettyApiService>(
      create: (_) => BettyApiService(baseUrl: dotenv.env['BETTY_API_BASE_URL'] ?? 'http://localhost:3000/api'),
    ),

    // Adapter
    ProxyProvider<BettyApiService, MapApiAdapter>(update: (_, apiService, _) => MapApiAdapter(apiService: apiService)),

    // Repository
    ProxyProvider<MapApiAdapter, IMapRepository>(
      update: (_, apiAdapter, _) => MapRepositoryImpl(apiAdapter: apiAdapter),
    ),

    // Use Cases
    ProxyProvider<IMapRepository, GetCurrentLocationUseCase>(
      update: (_, repository, _) => GetCurrentLocationUseCase(repository),
    ),
    ProxyProvider<IMapRepository, GetVehicleLocationUseCase>(
      update: (_, repository, _) => GetVehicleLocationUseCase(repository),
    ),
    ProxyProvider<IMapRepository, StreamLocationUpdatesUseCase>(
      update: (_, repository, _) => StreamLocationUpdatesUseCase(repository),
    ),
    ProxyProvider<IMapRepository, ToggleMapViewUseCase>(update: (_, repository, _) => ToggleMapViewUseCase(repository)),

    // Provider
    ChangeNotifierProxyProvider4<
      GetCurrentLocationUseCase,
      GetVehicleLocationUseCase,
      StreamLocationUpdatesUseCase,
      ToggleMapViewUseCase,
      MapProvider
    >(
      create: (context) {
        final apiService = BettyApiService(baseUrl: dotenv.env['BETTY_API_BASE_URL'] ?? 'http://localhost:3000/api');
        final apiAdapter = MapApiAdapter(apiService: apiService);
        final repository = MapRepositoryImpl(apiAdapter: apiAdapter);
        return MapProvider(
          getCurrentLocationUseCase: GetCurrentLocationUseCase(repository),
          getVehicleLocationUseCase: GetVehicleLocationUseCase(repository),
          streamLocationUpdatesUseCase: StreamLocationUpdatesUseCase(repository),
          toggleMapViewUseCase: ToggleMapViewUseCase(repository),
        );
      },
      update: (_, getCurrentUseCase, getVehicleUseCase, streamUseCase, toggleUseCase, previous) =>
          previous ??
          MapProvider(
            getCurrentLocationUseCase: getCurrentUseCase,
            getVehicleLocationUseCase: getVehicleUseCase,
            streamLocationUpdatesUseCase: streamUseCase,
            toggleMapViewUseCase: toggleUseCase,
          ),
    ),
  ];
}
