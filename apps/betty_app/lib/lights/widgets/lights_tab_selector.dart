import 'package:betty_app/lights/bloc/lights_bloc.dart';
import 'package:betty_app/lights/bloc/lights_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LightsTabSelector extends StatelessWidget {
  final int currentPage;

  const LightsTabSelector({super.key, required this.currentPage});

  void onPageChanged(BuildContext context, int page) async {
    final bloc = context.read<LightsBloc>();
    if (page == bloc.state.currentPage) return;

    bloc.add(ChangePageEvent(page));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E1E1E).withValues(alpha: 0.1), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabButton(
            label: 'Exterior',
            icon: Icons.directions_car_rounded,
            isActive: currentPage == 0,
            onTap: () => onPageChanged(context, 0),
          ),
          const SizedBox(width: 4),
          _TabButton(
            label: 'Interior',
            icon: Icons.weekend_rounded,
            isActive: currentPage == 1,
            onTap: () => onPageChanged(context, 1),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF667eea).withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? const Color(0xFF667eea) : const Color(0xFF1E1E1E).withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFF667eea) : const Color(0xFF1E1E1E).withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
