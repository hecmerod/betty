import 'package:flutter/material.dart';

class SecondaryPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final double backgroundOpacity;
  final Widget? customTitle;

  const SecondaryPageAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.backgroundOpacity = 1.0,
    this.customTitle,
  }) : assert(backgroundOpacity >= 0.0 && backgroundOpacity <= 1.0, 'backgroundOpacity must be between 0.0 and 1.0');

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: backgroundOpacity),
      elevation: 0,
      centerTitle: true,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E1E).withValues(alpha: 0.1), width: 1.5),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E1E1E)),
            onPressed: onBackPressed ?? () => Navigator.pop(context),
          ),
        ),
      ),
      title:
          customTitle ??
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
          ),
      actions: customTitle != null && actions == null
          ? [
              // Espaciador para balancear el leading cuando hay customTitle
              const SizedBox(width: 56),
            ]
          : actions,
    );
  }
}
