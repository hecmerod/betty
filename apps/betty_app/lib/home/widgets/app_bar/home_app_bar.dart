import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/navigation/bloc/navigation_bloc.dart';
import '../../../shared/navigation/bloc/navigation_event.dart';
import '../../../shared/navigation/routes.dart';
import 'notification_icon.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: GestureDetector(
        onTap: () {
          context.read<NavigationBloc>().add(const NavigateToPage(Routes.terminal));
        },
        child: Row(
          children: [
            Image.asset('assets/betty-icon.png', width: 44, height: 44),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Betty',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1E1E),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'la fragoneta',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF1E1E1E).withValues(alpha: 0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: const [Padding(padding: EdgeInsets.only(right: 24.0), child: NotificationIcon())],
    );
  }
}
