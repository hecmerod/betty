import 'package:flutter/material.dart';

class VehicleLocationButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const VehicleLocationButton({super.key, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.local_shipping),
      label: const Text('Furgoneta'),
    );
  }
}
