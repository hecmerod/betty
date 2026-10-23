import 'package:betty_app/alarm/infrastructure/di/alarm_providers.dart';
import 'package:betty_app/batteries/infrastructure/di/batteries_providers.dart';
import 'package:betty_app/map/infrastructure/di/map_providers.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ...alarmProviders,
  ...batteriesProviders,
  ...mapProviders,
];
