import 'package:flutter/material.dart';

class NavigationItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;

  const NavigationItem({required this.label, required this.icon, this.activeIcon});
}
