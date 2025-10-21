import 'package:flutter/material.dart';
import '../services/alarm_service.dart';

class AlarmStatusButton extends StatefulWidget {
  const AlarmStatusButton({super.key});

  @override
  State<AlarmStatusButton> createState() => _AlarmStatusButtonState();
}

class _AlarmStatusButtonState extends State<AlarmStatusButton> {
  final _alarmService = AlarmService.instance;

  bool _alarmActive = false;
  bool _isLoadingAlarm = true;
  bool _isTogglingAlarm = false;

  @override
  void initState() {
    super.initState();
    _loadAlarmStatus();
  }

  Future<void> _loadAlarmStatus() async {
    try {
      final status = await _alarmService.getAlarmStatus();
      if (mounted) {
        setState(() {
          _alarmActive = status;
          _isLoadingAlarm = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAlarm = false;
        });
        _showSnackBar('Error al cargar el estado de la alarma', isError: true);
      }
    }
  }

  Future<void> _toggleAlarm() async {
    setState(() {
      _isTogglingAlarm = true;
    });

    try {
      final newStatus = await _alarmService.toggleAlarm(_alarmActive);
      if (mounted) {
        setState(() {
          _alarmActive = newStatus;
          _isTogglingAlarm = false;
        });

        _showSnackBar(newStatus ? 'Alarma activada' : 'Alarma desactivada', isError: false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTogglingAlarm = false;
        });
        _showSnackBar('Error al cambiar el estado de la alarma', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _alarmActive ? Colors.green : Colors.red;
    final isLoading = _isLoadingAlarm || _isTogglingAlarm;

    return Expanded(
      child: GestureDetector(
        onTap: isLoading ? null : _toggleAlarm,
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(color)),
                )
              else
                Icon(Icons.shield, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                'Alarma',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  _alarmActive ? 'ON' : 'OFF',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
