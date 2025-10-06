import 'package:flutter/material.dart';

class NavigationItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final Widget page;

  const NavigationItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    required this.page,
  });
}