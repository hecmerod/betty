import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/theme/app_theme.dart';
import 'core/di/dependency_injection.dart';
import 'core/services/firebase_notification_service.dart';
import 'core/config/firebase_config.dart';
import 'notification/notification_handler.dart';
import 'camera/camera.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  NotificationHandler.instance.handleBackgroundMessage(message);

  final data = message.data;
  if (data.containsKey('type')) {
    switch (data['type']) {
      case 'security_alert':
        break;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _initializeNotifications();
  runApp(const BettyApp());
}

Future<void> _initializeNotifications() async {
  await FirebaseNotificationService.instance.initialize();
  for (final topic in FirebaseConfig.defaultTopics) {
    await FirebaseNotificationService.instance.subscribeToTopic(topic);
  }
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
        home: const NotificationWrapper(),
      ),
    );
  }
}

class NotificationWrapper extends StatefulWidget {
  const NotificationWrapper({super.key});

  @override
  State<NotificationWrapper> createState() => _NotificationWrapperState();
}

class _NotificationWrapperState extends State<NotificationWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationHandler.instance.initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const CameraPage();
  }
}
