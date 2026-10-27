import 'package:betty_app/core/config/app_config.dart';
import 'package:betty_app/home/presentation/widgets/app_bar/app_bar_notifications_icon.dart';
import 'package:betty_app/home/presentation/widgets/app_bar/batteries/battery_percent_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final String appLogo = AppConfig.instance.appLogo;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      scrolledUnderElevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      foregroundColor: const Color(0xFF1E1E1E),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      shape: const Border(bottom: BorderSide(color: Color(0xFFE6E6E6))),
      title: Row(
        children: [
          Image.asset(appLogo, width: 44, height: 44),
          const Spacer(),
          const BatteryPercentChip(),
          const SizedBox(width: 4),
          const AppBarNotificationsIcon(),
        ],
      ),
    );
  }
}
