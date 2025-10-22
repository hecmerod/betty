import 'package:flutter/material.dart';
import 'dart:ui';
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
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isLoadingAlarm || _isTogglingAlarm;
    final gradient = _alarmActive
        ? const LinearGradient(colors: [Color(0xFF43e97b), Color(0xFF38f9d7)])
        : const LinearGradient(colors: [Color(0xFFff6b6b), Color(0xFFee5a6f)]);

    return GestureDetector(
      onTap: isLoading ? null : _toggleAlarm,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              gradient: gradient.scale(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: (_alarmActive ? const Color(0xFF43e97b) : const Color(0xFFff6b6b)).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_alarmActive ? const Color(0xFF43e97b) : const Color(0xFFff6b6b)).withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.shield_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Alarma',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.3),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (_alarmActive ? const Color(0xFF43e97b) : const Color(0xFFff6b6b)).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _alarmActive ? 'ACTIVA' : 'INACTIVA',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
