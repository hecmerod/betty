import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_bloc.dart';
import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_event.dart';
import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_state.dart';
import 'package:betty_app/home/presentation/helpers/home_routes_to_index_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeNavigationBar extends StatelessWidget {
  const HomeNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeNavigationBloc, HomeNavigationState>(
      builder: (context, state) {
        final int index = HomeRoutesToIndexMapper.getIndexFromRoute(state.route);

        return NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (index) {
            final String route = HomeRoutesToIndexMapper.getRouteFromIndex(index);

            context.read<HomeNavigationBloc>().add(ScrollToPage(route));
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.camera_outlined), selectedIcon: Icon(Icons.camera), label: 'Camara'),
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mapa'),
          ],
        );
      },
    );
  }
}
