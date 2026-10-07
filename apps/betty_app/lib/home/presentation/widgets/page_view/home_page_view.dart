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
    final PageController controller = PageController(initialPage: 1);

    return BlocProvider(
      create: (context) => HomeNavigationBloc(),
      child: Scaffold(
        body: BlocListener<HomeNavigationBloc, HomeNavigationState>(
          listenWhen: (previous, current) => previous.route != current.route,
          listener: (context, state) => controller.animateToPage(
            HomeRoutesToIndexMapper.getIndexFromRoute(state.route),
            duration: Duration(milliseconds: 500),
            curve: Curves.ease,
          ),
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller,
            children: [const CameraPage(), const HomePage(), const MapPage()],
          ),
        ),
        bottomNavigationBar: HomeNavigationBar(),
      ),
    );
  }
}
