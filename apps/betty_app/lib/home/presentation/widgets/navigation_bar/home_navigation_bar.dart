import 'package:betty_app/core/navigation/presentation/routes.dart';
import 'package:betty_app/home/presentation/widgets/navigation_bar/home_navigation_bar_icon.dart';
import 'package:flutter/material.dart';

class HomeNavigationBar extends StatelessWidget {
  const HomeNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.height / 40),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height / 12,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          children: [
            HomeNavigationBarIcon(route: Routes.camera),
            Spacer(),
            HomeNavigationBarIcon(route: Routes.home),
            Spacer(),
            HomeNavigationBarIcon(route: Routes.map),
          ],
        ),
      ),
    );
  }
}
