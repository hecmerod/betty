import 'package:betty_app/core/navigation/presentation/routes.dart';
import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_bloc.dart';
import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_event.dart';
import 'package:betty_app/home/application/home_page_bloc/home_page_bloc.dart';
import 'package:betty_app/home/application/home_page_bloc/home_page_state.dart';
import 'package:betty_app/home/application/home_surface_bloc/home_surface_bloc.dart';
import 'package:betty_app/home/application/home_surface_bloc/home_surface_state.dart';
import 'package:betty_app/home/presentation/helpers/home_routes_to_index_mapper.dart';
import 'package:betty_app/home/presentation/widgets/app_bar/app_bar.dart';
import 'package:betty_app/home/presentation/widgets/home_surface_body.dart';
import 'package:betty_app/home/presentation/widgets/three_d_van_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final homeIndex = HomeRoutesToIndexMapper.getIndexFromRoute(Routes.home);

    return BlocProvider(
      create: (_) => HomeSurfaceBloc(),
      child: BlocListener<HomeSurfaceBloc, HomeSurfaceState>(
        listenWhen: (previous, current) =>
            previous.surface != current.surface &&
            current.surface != HomeSurface.dashboard,
        listener: (context, state) {
          context.read<HomeNavigationBloc>().add(
            const ScrollToPage(Routes.home),
          );
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: BlocSelector<HomePageBloc, HomePageState, bool>(
                selector: (state) => state.activePage == homeIndex,
                builder: (context, isHome) => ThreeDVanViewer(isActive: isHome),
              ),
            ),
            const Scaffold(
              backgroundColor: Colors.transparent,
              appBar: CustomAppBar(),
              body: HomeSurfaceBody(),
            ),
          ],
        ),
      ),
    );
  }
}
