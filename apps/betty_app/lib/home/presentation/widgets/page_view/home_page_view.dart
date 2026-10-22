import 'package:betty_app/camera/presentation/camera_page.dart';
import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_bloc.dart';
import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_state.dart';
import 'package:betty_app/home/presentation/helpers/home_routes_to_index_mapper.dart';
import 'package:betty_app/home/presentation/home_page.dart';
import 'package:betty_app/home/presentation/widgets/navigation_bar/home_navigation_bar.dart';
import 'package:betty_app/map/presentation/map_page.dart';
import 'package:betty_app/core/navigation/presentation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  static const routes = [Routes.camera, Routes.home, Routes.map];

  @override
  Widget build(BuildContext context) {
    int page = 1;

    final PageController controller = PageController(initialPage: page);

    return BlocProvider(
      create: (context) => HomeNavigationBloc(),
      child: Scaffold(
        body: BlocListener<HomeNavigationBloc, HomeNavigationState>(
          listenWhen: (previous, current) => previous.route != current.route,
          listener: (context, state) {
            int destinationIndex = HomeRoutesToIndexMapper.getIndexFromRoute(state.route);

            int pageDistance = (page - destinationIndex).abs();

            pageDistance > 1
                ? controller.jumpToPage(destinationIndex)
                : controller.animateToPage(destinationIndex, duration: Duration(milliseconds: 300), curve: Curves.ease);

            page = destinationIndex;
          },
          child: Stack(
            children: [
              PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: controller,
                children: [const CameraPage(), const HomePage(), const MapPage()],
              ),
              Positioned(left: 0, right: 0, bottom: 0, child: HomeNavigationBar()),
            ],
          ),
        ),
      ),
    );
  }
}
