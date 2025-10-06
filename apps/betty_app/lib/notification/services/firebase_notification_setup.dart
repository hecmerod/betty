import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../firebase_options.dart';
import 'background_message_handler.dart';
import 'notification_initializer.dart';

class FirebaseNotificationSetup {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await NotificationInitializer.initialize();
    } catch (e) {
      // Log el error pero permite que la app continue
    }
  }
}
