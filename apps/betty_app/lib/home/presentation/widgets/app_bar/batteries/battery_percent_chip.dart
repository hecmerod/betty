import 'package:betty_app/home/application/home_batteries_bloc/home_batteries_bloc.dart';
import 'package:betty_app/home/application/home_batteries_bloc/home_batteries_state.dart';
import 'package:betty_app/home/presentation/widgets/app_bar/batteries/battery_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatteryPercentChip extends StatelessWidget {
  const BatteryPercentChip({
    super.key,
    required this.onTap,
    this.selected = false,
  });

  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBatteriesBloc, HomeBatteriesState>(
      builder: (context, state) {
        final int? percent = state.chargePercent;
        if (percent == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: batteryGradient(percent),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? const Color(0xFF1E1E1E) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              '$percent%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
        );
      },
    );
  }
}
