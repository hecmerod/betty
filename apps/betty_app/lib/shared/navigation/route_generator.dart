import 'package:betty_app/notifications/presentation/notifications_page.dart';
import 'package:betty_app/shared/navigation/routes.dart';
import 'package:flutter/material.dart';
import '../../home/presentation/home_page.dart';

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

      case Routes.notifications:
        return _buildPageRoute(page: const NotificationsPage(), settings: settings);

      default:
        return null;
    }
  }

  static Widget? getPageWidget(String routeName) {
    switch (routeName) {
      case Routes.home:
        return const HomePage();
      default:
        return null;
    }
  }
}
