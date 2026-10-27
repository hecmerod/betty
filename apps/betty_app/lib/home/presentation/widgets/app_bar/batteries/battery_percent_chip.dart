import 'package:betty_app/core/navigation/application/navigation_bloc/navigation_bloc.dart';
import 'package:betty_app/core/navigation/application/navigation_bloc/navigation_event.dart';
import 'package:betty_app/core/navigation/presentation/routes.dart';
import 'package:betty_app/home/application/home_batteries_bloc/home_batteries_bloc.dart';
import 'package:betty_app/home/application/home_batteries_bloc/home_batteries_state.dart';
import 'package:betty_app/home/presentation/widgets/app_bar/batteries/battery_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatteryPercentChip extends StatelessWidget {
  const BatteryPercentChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBatteriesBloc, HomeBatteriesState>(
      builder: (context, state) {
        final int? percent = state.chargePercent;
        if (percent == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => context.read<NavigationBloc>().add(const NavigateToPage(Routes.batteries)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(gradient: batteryGradient(percent), borderRadius: BorderRadius.circular(12)),
            child: Text(
              '$percent%',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.4),
            ),
          ),
        );
      },
    );
  }
}
