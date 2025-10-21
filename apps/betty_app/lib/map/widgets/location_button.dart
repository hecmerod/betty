import 'package:flutter/material.dart';

class LocationButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const LocationButton({super.key, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.my_location),
    );
  }
}
