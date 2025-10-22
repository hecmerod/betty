import 'package:flutter/material.dart';
import 'dart:ui';
import '../../shared/theme/app_theme.dart';

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.primaryGradientMiddle),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
