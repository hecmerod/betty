import 'package:betty_app/core/navigation/presentation/routes.dart';
import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_bloc.dart';
import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeNavigationBarIcon extends StatelessWidget {
  const HomeNavigationBarIcon({super.key, required this.route, required this.selected});

  final String route;
  final bool selected;

  static const Map<String, IconData> _icons = {
    Routes.home: Icons.home_outlined,
    Routes.map: Icons.map_outlined,
    Routes.alarm: Icons.alarm_outlined,
  };

  static const Map<String, IconData> _selectedIcons = {
    Routes.home: Icons.home,
    Routes.map: Icons.map,
    Routes.alarm: Icons.alarm,
  };

  static const Map<String, String> _labels = {Routes.alarm: 'Alarma', Routes.home: 'Inicio', Routes.map: 'Mapa'};

  static const Map<String, Key> keys = {
    Routes.alarm: Key('navAlarm'),
    Routes.home: Key('navHome'),
    Routes.map: Key('navMap'),
  };

  static const Color _ink = Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: keys[route],
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (selected) return;
        context.read<HomeNavigationBloc>().add(ScrollToPage(route));
      },
      child: SizedBox.expand(
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: selected ? 1 : 0),
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          builder: (context, progress, _) {
            final Color color = Color.lerp(_ink.withValues(alpha: 0.5), Colors.white, progress)!;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: 1 - progress,
                        child: Icon(_icons[route], size: 22, color: color),
                      ),
                      Opacity(
                        opacity: progress,
                        child: Icon(_selectedIcons[route], size: 22, color: color),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _labels[route]!,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    height: 1.1,
                    fontWeight: progress > 0.5 ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
