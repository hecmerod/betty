import 'package:flutter/material.dart';

class ClickableIcon extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final VoidCallback onTap;
  final ValueNotifier<bool> state;

  const ClickableIcon({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.onTap,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 15),
        child: ValueListenableBuilder<bool>(
          valueListenable: state,
          builder: (context, isSelected, _) {
            return Icon(size: 30, isSelected ? selectedIcon : icon);
          },
        ),
      ),
    );
  }
}
