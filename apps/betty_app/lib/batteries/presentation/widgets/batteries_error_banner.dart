import 'package:betty_app/batteries/application/batteries_bloc/batteries_bloc.dart';
import 'package:betty_app/batteries/application/batteries_bloc/batteries_event.dart';
import 'package:betty_app/batteries/application/batteries_bloc/batteries_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatteriesErrorBanner extends StatelessWidget {
  const BatteriesErrorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BatteriesBloc, BatteriesState>(
      builder: (context, state) {
        final message = state.errorMessage;
        if (message == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFE11D48),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.read<BatteriesBloc>().add(const WatchBatteries()),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
