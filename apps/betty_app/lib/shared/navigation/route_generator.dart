import 'package:betty_app/shared/navigation/routes.dart';
import 'package:flutter/material.dart';
import '../../battery/battery_detail_page.dart';
import '../../camera/camera_page.dart';
import '../../home/home_page.dart';
import '../../terminal/terminal_page.dart';
import '../../lights/lights_page.dart';
import '../../map/map_page.dart';
import '../../notifications/notifications_page.dart';
import '../../settings/settings_page.dart';

class RouteGenerator {
  // Método helper para crear transiciones personalizadas
  static PageRouteBuilder _buildPageRoute({required Widget page, RouteSettings? settings}) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.95,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
    );
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return _buildPageRoute(page: const HomePage(), settings: settings);

      case Routes.terminal:
        return PageRouteBuilder(
          settings: settings,
          opaque: false, // Permite ver la página anterior
          pageBuilder: (context, animation, secondaryAnimation) => const TerminalPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child; // Sin transición, el widget ya tiene su propia animación
          },
        );

      case Routes.batteryDetail:
        return _buildPageRoute(page: const BatteryDetailPage(), settings: settings);

      case Routes.camera:
        return _buildPageRoute(page: const CameraPage(), settings: settings);

      case Routes.lights:
        return _buildPageRoute(page: const LightsPage(), settings: settings);

      case Routes.map:
        return _buildPageRoute(page: const MapPage(), settings: settings);

      case Routes.notifications:
        return _buildPageRoute(page: const NotificationsPage(), settings: settings);

      case Routes.settings:
        return _buildPageRoute(page: const SettingsPage(), settings: settings);

      default:
        return null;
    }
  }

  static Widget? getPageWidget(String routeName) {
    switch (routeName) {
      case Routes.home:
        return const HomePage();

      case Routes.terminal:
        return const TerminalPage();

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
