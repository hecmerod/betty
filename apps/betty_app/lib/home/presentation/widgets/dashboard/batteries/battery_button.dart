import 'package:betty_app/core/navigation/application/navigation_bloc/navigation_bloc.dart';
import 'package:betty_app/core/navigation/application/navigation_bloc/navigation_event.dart';
import 'package:betty_app/core/navigation/presentation/routes.dart';
import 'package:betty_app/home/application/home_batteries_bloc/home_batteries_bloc.dart';
import 'package:betty_app/home/application/home_batteries_bloc/home_batteries_state.dart';
import 'package:betty_app/home/presentation/widgets/dashboard/batteries/battery_glyph.dart';
import 'package:betty_app/home/presentation/widgets/dashboard/batteries/battery_percent_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatteryButton extends StatelessWidget {
  const BatteryButton({super.key});

  @override
  Widget build(BuildContext context) {
    final double pillHeight = MediaQuery.sizeOf(context).height / 12;

    return BlocBuilder<HomeBatteriesBloc, HomeBatteriesState>(
      builder: (context, state) {
        final int? percent = state.chargePercent;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 12, spreadRadius: 2)],
          ),
          child: GestureDetector(
            onTap: () => context.read<NavigationBloc>().add(const NavigateToPage(Routes.batteries)),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: pillHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    BatteryGlyph(percent: percent, charging: state.isCharging),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Baterías',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1E1E),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    if (percent != null) BatteryPercentChip(percent: percent),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
