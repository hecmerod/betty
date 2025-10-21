import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';

class AlarmControlWidget extends StatefulWidget {
  const AlarmControlWidget({super.key});

  @override
  State<AlarmControlWidget> createState() => _AlarmControlWidgetState();
}

class _AlarmControlWidgetState extends State<AlarmControlWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlarmProvider>().loadAlarmStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlarmProvider>(
      builder: (context, alarmProvider, child) {
        if (alarmProvider.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [CircularProgressIndicator(), SizedBox(height: 10), Text('Cargando estado de la alarma...')],
              ),
            ),
          );
        }

        if (alarmProvider.errorMessage != null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 10),
                  Text(
                    alarmProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(onPressed: () => alarmProvider.loadAlarmStatus(), child: const Text('Reintentar')),
                ],
              ),
            ),
          );
        }

        final alarmStatus = alarmProvider.alarmStatus;
        if (alarmStatus == null) {
          return const Card(
            child: Padding(padding: EdgeInsets.all(16.0), child: Text('No se pudo cargar el estado de la alarma')),
          );
        }

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      alarmStatus.isActive ? Icons.security : Icons.security_outlined,
                      size: 48,
                      color: alarmStatus.isActive ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado de la Alarma',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          alarmStatus.isActive ? 'ACTIVADA' : 'DESACTIVADA',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: alarmStatus.isActive ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: alarmProvider.isLoading ? null : () => alarmProvider.toggleAlarm(),
                    icon: Icon(alarmStatus.isActive ? Icons.security_outlined : Icons.security),
                    label: Text(alarmStatus.isActive ? 'Desactivar Alarma' : 'Activar Alarma'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: alarmStatus.isActive ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Última actualización: ${_formatDateTime(alarmStatus.timestamp)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
