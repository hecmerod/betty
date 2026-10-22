import 'package:betty_app/core/navigation/presentation/routes.dart';
import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_bloc.dart';
import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_event.dart';
import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_state.dart';
import 'package:betty_app/shared/widgets/clickable_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeNavigationBarIcon extends StatelessWidget {
  final String route;

  HomeNavigationBarIcon({super.key, required this.route}) : selected = ValueNotifier(route == Routes.home);

  final ValueNotifier<bool> selected;

  static const Map<String, IconData> _icons = {
    Routes.home: Icons.home_outlined,
    Routes.map: Icons.map_outlined,
    Routes.camera: Icons.camera_outlined,
  };

  static const Map<String, IconData> _selectedIcons = {
    Routes.home: Icons.home,
    Routes.map: Icons.map,
    Routes.camera: Icons.camera,
  };

  void _onTap(BuildContext context) {
    if (!selected.value) context.read<HomeNavigationBloc>().add(ScrollToPage(route));
    selected.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeNavigationBloc, HomeNavigationState>(
      listenWhen: (previous, current) => previous.route != current.route,
      listener: (context, state) => selected.value = state.route == route,
      child: ClickableIcon(
        icon: _icons[route]!,
        selectedIcon: _selectedIcons[route]!,
        onTap: () => _onTap(context),
        state: selected,
      ),
    );
  }
}
