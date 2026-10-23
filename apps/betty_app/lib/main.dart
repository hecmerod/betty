import 'package:betty_app/core/di/providers.dart';
import 'package:betty_app/firebase_options.dart';
import 'package:betty_app/home/presentation/widgets/page_view/home_page_view.dart';
import 'package:betty_app/core/navigation/presentation/navigation_root.dart';
import 'package:betty_app/notifications/infrastructure/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'shared/theme/app_theme.dart';
import 'core/navigation/navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
  );

  runApp(MultiRepositoryProvider(providers: providers, child: const BettyApp()));
}

class BettyApp extends StatelessWidget {
  const BettyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Betty',
      theme: AppTheme.lightTheme,
      navigatorKey: Navigation.instance.navigatorKey,
      scaffoldMessengerKey: Navigation.instance.scaffoldMessengerKey,
      builder: (context, child) =>
          NavigationRoot(navigatorKey: Navigation.instance.navigatorKey, child: child ?? const SizedBox()),
      home: HomePageView(),
    );
  }
}
