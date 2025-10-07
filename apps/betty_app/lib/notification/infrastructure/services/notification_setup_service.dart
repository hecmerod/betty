import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../firebase_options.dart';
import '../../notification_handler.dart';
import '../../../shared/error/services/error_service.dart';
import '../../../core/services/firebase_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationHandler.instance.handleBackgroundMessage(message);
}

class NotificationSetupService {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await FirebaseNotificationService.instance.initialize();
    } catch (e, stackTrace) {
      ErrorService().reportFirebaseError(
        message: 'Error crítico al inicializar el sistema de notificaciones',
        technicalDetails: 'NotificationSetupService error: $e',
        stackTrace: stackTrace,
      );
    }
  }
}
