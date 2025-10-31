import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/alarm_bloc.dart';
import '../bloc/alarm_state.dart';
import 'sensor_list_item.dart';

class SensorList extends StatelessWidget {
  const SensorList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmBloc, AlarmState>(
      builder: (context, state) {
        if (state.sensors.isEmpty && !state.isLoadingSensors) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sensors_off_rounded, size: 64, color: const Color(0xFF1E1E1E).withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text(
                  'No hay sensores disponibles',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF1E1E1E).withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: const ClampingScrollPhysics(),
          itemCount: state.sensors.length,
          itemBuilder: (context, index) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
                );
              },
              child: SensorListItem(sensor: state.sensors[index]),
            );
          },
        );
      },
    );
  }
}
