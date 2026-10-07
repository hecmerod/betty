import 'package:betty_app/home/presentation/widgets/page_view/home_page_view.dart';

class HomeRoutesToIndexMapper {
  static int getIndexFromRoute(String route) => HomePageView.routes.indexOf(route);
  static String getRouteFromIndex(int index) => HomePageView.routes[index];
}
