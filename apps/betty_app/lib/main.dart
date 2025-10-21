import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'notifications/services/notification_service.dart';
import 'home/home_page.dart';
import 'shared/theme/app_theme.dart';
import 'shared/navigation/navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
  );

  runApp(const BettyApp());
}

class BettyApp extends StatelessWidget {
  const BettyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Betty App',
      theme: AppTheme.lightTheme,
      navigatorKey: Navigation.instance.navigatorKey,
      scaffoldMessengerKey: Navigation.instance.scaffoldMessengerKey,
      home: const HomePage(),
    );
  }
}
