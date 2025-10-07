import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/di/dependency_injection.dart';
import 'notification/infrastructure/services/notification_setup_service.dart';
import 'bottom_navigator_bar/presentation/pages/main_navigation_page.dart';
import 'notification/presentation/widgets/notification_wrapper.dart';
import 'shared/error/services/error_service.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: ".env");
      await NotificationSetupService.initialize();
      runApp(const BettyApp());
    },
    (error, stackTrace) {
      ErrorService().reportUnknownError(
        exception: error,
        stackTrace: stackTrace,
        customMessage: 'Error no manejado en la aplicación',
      );
    },
  );
}

class BettyApp extends StatelessWidget {
  const BettyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    ErrorService().initialize(navigatorKey);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DependencyInjection.createCameraProvider()),
        ChangeNotifierProvider(create: (_) => DependencyInjection.createAlarmProvider()),
      ],
      child: MaterialApp(
        title: 'Betty Camera Control',
        navigatorKey: navigatorKey,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const NotificationWrapper(child: MainNavigationPage()),
      ),
    );
  }
}
