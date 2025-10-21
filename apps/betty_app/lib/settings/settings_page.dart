import 'package:flutter/material.dart';
import 'widgets/status_button.dart';
import 'widgets/alarm_status_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes'), elevation: 0),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'SEGURIDAD',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const Row(
                  children: [
                    AlarmStatusButton(),
                    StatusButton(icon: Icons.camera_alt, title: 'Cámara'),
                  ],
                ),

                const SizedBox(height: 8),

                const Padding(
                  padding: EdgeInsets.only(left: 4, top: 16, bottom: 8),
                  child: Text(
                    'SISTEMA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const Row(
                  children: [
                    StatusButton(icon: Icons.wifi, title: 'Wi-Fi'),
                    StatusButton(icon: Icons.gps_fixed, title: 'GPS'),
                  ],
                ),

                const SizedBox(height: 8),

                const Padding(
                  padding: EdgeInsets.only(left: 4, top: 16, bottom: 8),
                  child: Text(
                    'NOTIFICACIONES',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const Row(
                  children: [
                    StatusButton(icon: Icons.notifications_active, title: 'Alertas'),
                    StatusButton(icon: Icons.volume_up, title: 'Sonidos'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
