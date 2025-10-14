import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'domain/repositories/i_map_repository.dart';
import 'domain/use_cases/get_current_location_use_case.dart';
import 'domain/use_cases/stream_location_updates_use_case.dart';
import 'domain/use_cases/toggle_map_view_use_case.dart';
import 'infrastructure/repositories/map_repository_impl.dart';
import 'presentation/providers/map_provider.dart';

class MapModule {
  static List<SingleChildWidget> get providers => [
    // Repository
    Provider<IMapRepository>(create: (_) => MapRepositoryImpl()),

    // Use Cases
    ProxyProvider<IMapRepository, GetCurrentLocationUseCase>(
      update: (_, repository, _) => GetCurrentLocationUseCase(repository),
    ),
    ProxyProvider<IMapRepository, StreamLocationUpdatesUseCase>(
      update: (_, repository, _) => StreamLocationUpdatesUseCase(repository),
    ),
    ProxyProvider<IMapRepository, ToggleMapViewUseCase>(update: (_, repository, _) => ToggleMapViewUseCase(repository)),

    // Provider
    ChangeNotifierProxyProvider3<
      GetCurrentLocationUseCase,
      StreamLocationUpdatesUseCase,
      ToggleMapViewUseCase,
      MapProvider
    >(
      create: (_) => MapProvider(
        getCurrentLocationUseCase: GetCurrentLocationUseCase(MapRepositoryImpl()),
        streamLocationUpdatesUseCase: StreamLocationUpdatesUseCase(MapRepositoryImpl()),
        toggleMapViewUseCase: ToggleMapViewUseCase(MapRepositoryImpl()),
      ),
      update: (_, getCurrentUseCase, streamUseCase, toggleUseCase, previous) =>
          previous ??
          MapProvider(
            getCurrentLocationUseCase: getCurrentUseCase,
            streamLocationUpdatesUseCase: streamUseCase,
            toggleMapViewUseCase: toggleUseCase,
          ),
    ),
  ];
}
