import 'package:betty_app/home/presentation/widgets/app_bar/app_bar_notifications_icon.dart';
import 'package:betty_app/core/config/app_config.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final String appLogo = AppConfig.instance.appLogo;

    return AppBar(
      automaticallyImplyLeading: false,
      title: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text('Betty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Row(children: [Image.asset(appLogo, width: 44, height: 44), const Spacer(), AppBarNotificationsIcon()]),
        ],
      ),
    );
  }
}
