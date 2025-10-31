import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../bloc/alarm_bloc.dart';
import '../bloc/alarm_event.dart';
import '../bloc/alarm_state.dart';

class AlarmMainButton extends StatelessWidget {
  const AlarmMainButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmBloc, AlarmState>(
      builder: (context, state) {
        final isLoading = state.isLoadingAlarm || state.isTogglingAlarm;
        final isActive = state.isAlarmActive;
        final hasError = state.errorMessage != null && !isLoading;
        final isDisabled = hasError;

        // Gradiente gris neutral para estado de carga o error
        final loadingGradient = const LinearGradient(colors: [Color(0xFF9E9E9E), Color(0xFF757575)]);

        final gradient = (isLoading || isDisabled)
            ? loadingGradient
            : (isActive
                  ? const LinearGradient(colors: [Color(0xFF43e97b), Color(0xFF38f9d7)])
                  : const LinearGradient(colors: [Color(0xFFff6b6b), Color(0xFFee5a6f)]));

        // Color del borde según el estado
        final borderColor = (isLoading || isDisabled)
            ? const Color(0xFF9E9E9E)
            : (isActive ? const Color(0xFF43e97b) : const Color(0xFFff6b6b));

        return Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: GestureDetector(
            onTap: (isLoading || isDisabled) ? null : () => context.read<AlarmBloc>().add(const ToggleAlarm()),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: gradient.scale(0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor.withValues(alpha: 0.3), width: 2),
                    boxShadow: [
                      BoxShadow(color: borderColor.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: gradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: borderColor.withValues(alpha: 0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.shield_rounded, color: Colors.white, size: 40),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alarma de Seguridad',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDisabled ? const Color(0xFF999999) : const Color(0xFF1E1E1E),
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: borderColor.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                isDisabled
                                    ? 'NO DISPONIBLE'
                                    : (isLoading ? 'CARGANDO...' : (isActive ? 'ACTIVA' : 'INACTIVA')),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
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
