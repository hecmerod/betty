import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../notification/notification_handler.dart';
import '../../../alarm/presentation/providers/alarm_provider.dart';
import '../../../alarm/presentation/widgets/alarm_control_widget.dart';

class PrimaryPage extends StatelessWidget {
  const PrimaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍓 Betty Primary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text('🍓 Bienvenido a Betty', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Página principal del sistema', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 40),

            Consumer<AlarmProvider>(
              builder: (context, alarmProvider, child) {
                return const AlarmControlWidget();
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                NotificationHandler.instance.testNotification();
              },
              icon: const Icon(Icons.notifications),
              label: const Text('Probar Notificación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
