import 'package:betty_app/map/domain/ports/device_location_port.dart';
import 'package:betty_app/map/domain/ports/server_gps_port.dart';
import 'package:betty_app/map/infrastructure/adapters/device_location_adapter.dart';
import 'package:betty_app/map/infrastructure/adapters/server_gps_adapter.dart';
import 'package:betty_app/shared/services/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> mapProviders = [
  RepositoryProvider<DeviceLocationPort>(
    create: (_) => DeviceLocationAdapter(),
  ),
  RepositoryProvider<ServerGpsPort>(
    create: (_) => ServerGpsAdapter(apiService: ApiService.instance),
  ),
];
