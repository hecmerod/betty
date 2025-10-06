import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/di/dependency_injection.dart';
import 'notification/notification.dart';
import 'camera/camera.dart';
import 'error/error.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runZonedGuarded(
    () async {
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

    return ChangeNotifierProvider(
      create: (_) => DependencyInjection.createCameraProvider(),
      child: MaterialApp(
        title: 'Betty Camera Control',
        navigatorKey: navigatorKey,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const NotificationWrapper(child: CameraPage()),
      ),
    );
  }
}
