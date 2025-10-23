import 'package:betty_app/shared/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/navigation/bloc/navigation_bloc.dart';
import '../../../shared/navigation/bloc/navigation_event.dart';
import 'notification_badge.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E1E1E).withValues(alpha: 0.1), width: 1.5),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_rounded, color: Color(0xFF1E1E1E)),
                onPressed: () {
                  context.read<NavigationBloc>().add(const NavigateToPage(Routes.notifications));
                },
              ),
            ),
          ),
        ),
        const NotificationBadge(),
      ],
    );
  }
}
