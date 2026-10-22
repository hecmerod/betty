import 'package:betty_app/core/navigation/presentation/routes.dart';

class HomeRoutesToIndexMapper {
  static const routes = [Routes.camera, Routes.home, Routes.map];

  static int getIndexFromRoute(String route) => routes.indexOf(route);
  static String getRouteFromIndex(int index) => routes[index];
}
