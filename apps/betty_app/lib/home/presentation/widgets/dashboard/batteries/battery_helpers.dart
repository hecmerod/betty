import 'package:flutter/material.dart';

LinearGradient batteryGradient(int percent) {
  if (percent <= 20) {
    return const LinearGradient(colors: [Color(0xFFff6b6b), Color(0xFFee5a6f)]);
  }
  if (percent <= 50) {
    return const LinearGradient(colors: [Color(0xFFfa709a), Color(0xFFfee140)]);
  }
  return const LinearGradient(colors: [Color(0xFF43e97b), Color(0xFF38f9d7)]);
}

IconData batteryIconFor(int percent, bool charging) {
  if (charging) return Icons.battery_charging_full;
  if (percent <= 10) return Icons.battery_0_bar;
  if (percent <= 25) return Icons.battery_1_bar;
  if (percent <= 40) return Icons.battery_2_bar;
  if (percent <= 55) return Icons.battery_3_bar;
  if (percent <= 70) return Icons.battery_4_bar;
  if (percent <= 85) return Icons.battery_5_bar;
  if (percent < 100) return Icons.battery_6_bar;
  return Icons.battery_full;
}
