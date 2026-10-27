import 'package:betty_app/batteries/application/batteries_bloc/batteries_bloc.dart';
import 'package:betty_app/batteries/application/batteries_bloc/batteries_event.dart';
import 'package:betty_app/batteries/application/batteries_bloc/batteries_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatteriesPlaceholder extends StatelessWidget {
  const BatteriesPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BatteriesBloc, BatteriesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final message = state.errorMessage ?? 'No hay baterías disponibles';

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  state.errorMessage == null
                      ? Icons.battery_unknown_rounded
                      : Icons.cloud_off_rounded,
                  size: 56,
                  color: const Color(0xFF1E1E1E).withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E1E1E).withValues(alpha: 0.7),
                  ),
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.read<BatteriesBloc>().add(
                      const WatchBatteries(force: true),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
