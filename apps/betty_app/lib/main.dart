import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/di/dependency_injection.dart';
import 'notification/notification.dart';
import 'camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await FirebaseNotificationSetup.initialize();
  runApp(const BettyApp());
}

class BettyApp extends StatelessWidget {
  const BettyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DependencyInjection.createCameraProvider(),
      child: MaterialApp(
        title: 'Betty Camera Control',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const NotificationWrapper(child: CameraPage()),
      ),
    );
  }
}
