import 'package:betty_app/terminal/bloc/terminal_bloc.dart';
import 'package:betty_app/terminal/bloc/terminal_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TerminalHeader extends StatelessWidget {
  const TerminalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withValues(alpha: 0.2),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.terminal, color: Color(0xFF1E1E1E), size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Betty Terminal',
            style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF1E1E1E), size: 20),
              onPressed: () => context.read<TerminalBloc>().add(const CloseTerminal()),
            ),
          ),
        ],
      ),
    );
  }
}
