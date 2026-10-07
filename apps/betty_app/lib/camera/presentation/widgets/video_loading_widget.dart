import 'package:flutter/material.dart';

class VideoLoadingWidget extends StatelessWidget {
  const VideoLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('loading'),
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(16)),
      child: SizedBox.expand(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Conectando al stream...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
