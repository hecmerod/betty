import 'package:flutter/material.dart';

class VideoErrorWidget extends StatelessWidget {
  final String error;

  const VideoErrorWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('error'),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
      child: SizedBox.expand(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off, size: 64, color: Colors.white54),
              const SizedBox(height: 16),
              Text('Error de conexión', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
