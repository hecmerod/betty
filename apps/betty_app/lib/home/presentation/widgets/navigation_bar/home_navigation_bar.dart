import 'package:betty_app/core/navigation/presentation/routes.dart';
import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_bloc.dart';
import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_state.dart';
import 'package:betty_app/home/presentation/widgets/navigation_bar/home_navigation_bar_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeNavigationBar extends StatelessWidget {
  const HomeNavigationBar({super.key});

  static const routes = [Routes.alarm, Routes.home, Routes.map];

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;
    final double inset = height / 40;
    final double barHeight = height / 12;

    return Padding(
      padding: EdgeInsets.all(inset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(barHeight / 2),
          border: Border.all(color: const Color(0xFFE6E6E6)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(barHeight / 2),
          child: SizedBox(
            height: barHeight,
            width: double.infinity,
            child: BlocBuilder<HomeNavigationBloc, HomeNavigationState>(
              buildWhen: (previous, current) => previous.route != current.route,
              builder: (context, state) {
                final int index = routes.indexOf(state.route).clamp(0, routes.length - 1);
                final double alignmentX = -1 + (2 * index / (routes.length - 1));

                return Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment(alignmentX, 0),
                      child: const FractionallySizedBox(
                        widthFactor: 1 / 3,
                        heightFactor: 1,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.all(Radius.circular(100)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (final route in routes)
                          Expanded(
                            child: HomeNavigationBarIcon(route: route, selected: state.route == route),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
