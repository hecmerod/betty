import 'package:betty_app/shared/navigation/bloc/navigation_bloc.dart';
import 'package:betty_app/shared/navigation/bloc/navigation_event.dart';
import 'package:betty_app/shared/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBarNotificationsIcon extends StatefulWidget {
  const AppBarNotificationsIcon({super.key});

  @override
  State<AppBarNotificationsIcon> createState() => _AppBarNotificationsIconState();
}

class _AppBarNotificationsIconState extends State<AppBarNotificationsIcon> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications, size: 35),
      onPressed: () => context.read<NavigationBloc>().add(const NavigateToPage(Routes.notifications)),
    );
  }
}
