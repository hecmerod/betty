import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../bloc/alarm_bloc.dart';
import '../bloc/alarm_event.dart';
import '../bloc/alarm_state.dart';
import '../models/sensor.dart';

class SensorListItem extends StatelessWidget {
  final Sensor sensor;

  const SensorListItem({super.key, required this.sensor});

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'motion_sensor_rounded':
        return Icons.motion_photos_on_rounded;
      case 'door_front':
        return Icons.door_front_door_rounded;
      case 'door_back':
        return Icons.door_back_door_rounded;
      case 'door_sliding':
        return Icons.door_sliding_rounded;
      case 'meeting_room':
        return Icons.meeting_room_rounded;
      case 'location_on':
        return Icons.location_on_rounded;
      default:
        return Icons.sensors_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmBloc, AlarmState>(
      builder: (context, state) {
        final isListening = sensor.isListening;
        final isAlarmActive = state.isAlarmActive;
        final isDisabled = !isAlarmActive;

        return Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E).withValues(alpha: isDisabled ? 0.03 : 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF1E1E1E).withValues(alpha: isDisabled ? 0.05 : 0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDisabled
                              ? const Color(0xFF1E1E1E).withValues(alpha: 0.05)
                              : (isListening
                                    ? const Color(0xFF43e97b).withValues(alpha: 0.2)
                                    : const Color(0xFF1E1E1E).withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getIconData(sensor.type.iconName),
                          color: isDisabled
                              ? const Color(0xFF999999)
                              : (isListening ? const Color(0xFF43e97b) : const Color(0xFF666666)),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sensor.type.displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDisabled ? const Color(0xFF999999) : const Color(0xFF1E1E1E),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isDisabled ? 'No disponible' : (isListening ? 'Activo' : 'Inactivo'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDisabled
                                    ? const Color(0xFF999999)
                                    : (isListening ? const Color(0xFF43e97b) : const Color(0xFF666666)),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IgnorePointer(
                        ignoring: isDisabled,
                        child: GestureDetector(
                          onTap: () {
                            context.read<AlarmBloc>().add(ToggleSensor(sensor.type));
                          },
                          child: Container(
                            width: 56,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: isDisabled
                                  ? null
                                  : (isListening
                                        ? const LinearGradient(colors: [Color(0xFF43e97b), Color(0xFF38f9d7)])
                                        : null),
                              color: isDisabled
                                  ? const Color(0xFF1E1E1E).withValues(alpha: 0.05)
                                  : (isListening ? null : const Color(0xFF1E1E1E).withValues(alpha: 0.1)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                AnimatedAlign(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  alignment: isListening ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: isDisabled ? const Color(0xFFCCCCCC) : Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0x20000000),
                                          blurRadius: isDisabled ? 2 : 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
