import 'package:betty_app/batteries/application/batteries_bloc/batteries_bloc.dart';
import 'package:betty_app/batteries/domain/ports/batteries_port.dart';
import 'package:betty_app/batteries/presentation/batteries_page.dart';
import 'package:betty_app/home/application/home_surface_bloc/home_surface_bloc.dart';
import 'package:betty_app/home/application/home_surface_bloc/home_surface_state.dart';
import 'package:betty_app/home/presentation/widgets/dashboard/home_dashboard.dart';
import 'package:betty_app/notifications/presentation/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeSurfaceBody extends StatelessWidget {
  const HomeSurfaceBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BatteriesBloc(batteriesPort: context.read<BatteriesPort>()),
      child: const _HomeSurfacePages(),
    );
  }
}

class _HomeSurfacePages extends StatelessWidget {
  const _HomeSurfacePages();

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;
    final double inset = height / 40;
    final double navClearance = inset * 2 + height / 12;

    return BlocBuilder<HomeSurfaceBloc, HomeSurfaceState>(
      buildWhen: (previous, current) => previous.surface != current.surface,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(inset, inset, inset, navClearance),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: switch (state.surface) {
              HomeSurface.dashboard => const SizedBox.expand(
                key: ValueKey(HomeSurface.dashboard),
                child: HomeDashboard(),
              ),
              HomeSurface.batteries => const SizedBox.expand(
                key: ValueKey(HomeSurface.batteries),
                child: BatteriesPage(),
              ),
              HomeSurface.notifications => const SizedBox.expand(
                key: ValueKey(HomeSurface.notifications),
                child: NotificationsPage(),
              ),
            },
          ),
        );
      },
    );
  }
}
