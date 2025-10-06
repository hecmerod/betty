import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../domain/repositories/i_gps_repository.dart';
import '../../domain/use_cases/get_current_location_use_case.dart';
import '../../domain/use_cases/stream_location_updates_use_case.dart';
import '../../domain/use_cases/toggle_map_view_use_case.dart';
import '../repositories/gps_repository_impl.dart';
import '../../presentation/providers/gps_provider.dart';

class GpsModule {
  static List<SingleChildWidget> get providers => [
    // Repository
    Provider<IGpsRepository>(create: (_) => GpsRepositoryImpl()),

    // Use Cases
    ProxyProvider<IGpsRepository, GetCurrentLocationUseCase>(
      update: (_, repository, __) => GetCurrentLocationUseCase(repository),
    ),
    ProxyProvider<IGpsRepository, StreamLocationUpdatesUseCase>(
      update: (_, repository, __) => StreamLocationUpdatesUseCase(repository),
    ),
    ProxyProvider<IGpsRepository, ToggleMapViewUseCase>(
      update: (_, repository, __) => ToggleMapViewUseCase(repository),
    ),

    // Provider
    ChangeNotifierProxyProvider3<
      GetCurrentLocationUseCase,
      StreamLocationUpdatesUseCase,
      ToggleMapViewUseCase,
      GpsProvider
    >(
      create: (_) => GpsProvider(
        getCurrentLocationUseCase: GetCurrentLocationUseCase(GpsRepositoryImpl()),
        streamLocationUpdatesUseCase: StreamLocationUpdatesUseCase(GpsRepositoryImpl()),
        toggleMapViewUseCase: ToggleMapViewUseCase(GpsRepositoryImpl()),
      ),
      update: (_, getCurrentUseCase, streamUseCase, toggleUseCase, previous) =>
          previous ??
          GpsProvider(
            getCurrentLocationUseCase: getCurrentUseCase,
            streamLocationUpdatesUseCase: streamUseCase,
            toggleMapViewUseCase: toggleUseCase,
          ),
    ),
  ];
}
