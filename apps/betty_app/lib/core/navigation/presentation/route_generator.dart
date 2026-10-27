import 'package:betty_app/core/navigation/presentation/routes.dart';
import 'package:flutter/material.dart';
import '../../../home/presentation/home_page.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
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
