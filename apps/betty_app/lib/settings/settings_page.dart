import 'package:betty_app/shared/widgets/secondary_page_app_bar.dart';
import 'package:flutter/material.dart';
import 'widgets/status_button.dart';
import 'widgets/alarm_status_button.dart';
import 'widgets/section_header.dart';
import 'widgets/app_info_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const SecondaryPageAppBar(title: 'Ajustes'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 150),
            const SectionHeader(title: 'SEGURIDAD'),
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
            const SectionHeader(title: 'SISTEMA'),
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
            const SectionHeader(title: 'NOTIFICACIONES'),
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
            const AppInfoCard(),
          ],
        ),
      ),
    );
  }
}
