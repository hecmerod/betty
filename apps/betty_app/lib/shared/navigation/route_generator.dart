import 'package:betty_app/shared/navigation/routes.dart';
import 'package:flutter/material.dart';
import '../../battery/battery_detail_page.dart';
import '../../camera/camera_page.dart';
import '../../home/home_page.dart';
import '../../lights/lights_page.dart';
import '../../map/map_page.dart';
import '../../notifications/notifications_page.dart';
import '../../settings/settings_page.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case Routes.batteryDetail:
        return MaterialPageRoute(builder: (_) => const BatteryDetailPage());

      case Routes.camera:
        return MaterialPageRoute(builder: (_) => const CameraPage());

      case Routes.lights:
        return MaterialPageRoute(builder: (_) => const LightsPage());

      case Routes.map:
        return MaterialPageRoute(builder: (_) => const MapPage());

      case Routes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());

      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());

      default:
        return null;
    }
  }

  static Widget? getPageWidget(String routeName) {
    switch (routeName) {
      case Routes.home:
        return const HomePage();

      case Routes.batteryDetail:
        return const BatteryDetailPage();

      case Routes.camera:
        return const CameraPage();

      case Routes.lights:
        return const LightsPage();

      case Routes.map:
        return const MapPage();

      case Routes.notifications:
        return const NotificationsPage();

      case Routes.settings:
        return const SettingsPage();

      default:
        return null;
    }
  }
}
