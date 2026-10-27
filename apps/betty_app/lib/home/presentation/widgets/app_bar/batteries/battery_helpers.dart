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
