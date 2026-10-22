import 'package:betty_app/alarm/domain/ports/camera_port.dart';
import 'package:betty_app/alarm/infrastructure/adapters/camera_adapter.dart';
import 'package:betty_app/core/config/app_config.dart';
import 'package:betty_app/shared/services/jwt_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> alarmProviders = [
  RepositoryProvider<CameraPort>(
    create: (_) => CameraAdapter(
      config: AppConfig.instance,
      jwtService: JwtService.instance,
    ),
  ),
];
