import 'package:betty_app/batteries/domain/ports/batteries_port.dart';
import 'package:betty_app/batteries/infrastructure/adapters/batteries_adapter.dart';
import 'package:betty_app/shared/services/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> batteriesProviders = [
  RepositoryProvider<BatteriesPort>(
    create: (_) => BatteriesAdapter(apiService: ApiService.instance),
  ),
];
