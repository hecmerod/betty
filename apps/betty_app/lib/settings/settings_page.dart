import 'package:flutter/material.dart';
import 'dart:ui';
import 'widgets/status_button.dart';
import 'widgets/alarm_status_button.dart';
import '../shared/theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text('Ajustes', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 150),
              _buildSectionHeader('SEGURIDAD'),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(child: AlarmStatusButton()),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatusButton(icon: Icons.videocam_rounded, title: 'Cámara'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('SISTEMA'),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: StatusButton(icon: Icons.wifi_rounded, title: 'Wi-Fi'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatusButton(icon: Icons.gps_fixed_rounded, title: 'GPS'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('NOTIFICACIONES'),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: StatusButton(icon: Icons.notifications_active_rounded, title: 'Alertas'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatusButton(icon: Icons.volume_up_rounded, title: 'Sonidos'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.9),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                    child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Betty v1.0.0',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sistema de Vigilancia Vehicular',
                          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
