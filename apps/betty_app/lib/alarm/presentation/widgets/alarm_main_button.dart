import 'dart:ui';

import 'package:betty_app/alarm/application/alarm_bloc/alarm_bloc.dart';
import 'package:betty_app/alarm/application/alarm_bloc/alarm_event.dart';
import 'package:betty_app/alarm/application/alarm_bloc/alarm_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlarmMainButton extends StatefulWidget {
  const AlarmMainButton({super.key});

  @override
  State<AlarmMainButton> createState() => _AlarmMainButtonState();
}

class _AlarmMainButtonState extends State<AlarmMainButton> {
  final TextEditingController _controller = TextEditingController();
  bool _passwordOpen = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final password = _controller.text.trim();
    if (password.length != 4) return;
    context.read<AlarmBloc>().add(SetAlarmPassword(password));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AlarmBloc, AlarmState>(
      listenWhen: (previous, current) =>
          previous.isSavingPassword &&
          !current.isSavingPassword &&
          current.successMessage != null,
      listener: (context, state) => _controller.clear(),
      child: BlocBuilder<AlarmBloc, AlarmState>(
        builder: (context, state) {
          final isLoading = state.isLoadingAlarm || state.isTogglingAlarm;
          final isActive = state.alarm.isActive;
          final isDisabled = state.errorMessage != null && !isLoading;
          final canToggle = !isLoading && !isDisabled;

          const loadingGradient = LinearGradient(
            colors: [Color(0xFF9E9E9E), Color(0xFF757575)],
          );
          final gradient = (isLoading || isDisabled)
              ? loadingGradient
              : (isActive
                    ? const LinearGradient(
                        colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFff6b6b), Color(0xFFee5a6f)],
                      ));
          final borderColor = (isLoading || isDisabled)
              ? const Color(0xFF9E9E9E)
              : (isActive ? const Color(0xFF43e97b) : const Color(0xFFff6b6b));

          return ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient.colors
                        .map((color) => color.withValues(alpha: 0.15))
                        .toList(),
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: borderColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: canToggle
                                ? () => context.read<AlarmBloc>().add(
                                    const ToggleAlarm(),
                                  )
                                : null,
                            behavior: HitTestBehavior.opaque,
                            child: Opacity(
                              opacity: isDisabled ? 0.5 : 1,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: gradient,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: borderColor.withValues(
                                            alpha: 0.5,
                                          ),
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
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.shield_rounded,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Alarma de Seguridad',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isDisabled
                                                ? const Color(0xFF999999)
                                                : const Color(0xFF1E1E1E),
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: gradient,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: borderColor.withValues(
                                                  alpha: 0.4,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            isDisabled
                                                ? 'NO DISPONIBLE'
                                                : (isLoading
                                                      ? 'CARGANDO...'
                                                      : (isActive
                                                            ? 'ACTIVA'
                                                            : 'INACTIVA')),
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
                        GestureDetector(
                          onTap: () =>
                              setState(() => _passwordOpen = !_passwordOpen),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: AnimatedRotation(
                              turns: _passwordOpen ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF1E1E1E),
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: _passwordOpen
                          ? Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: _PasswordSection(
                                controller: _controller,
                                password: state.alarm.password,
                                isLoading: state.isLoadingPassword,
                                isSaving: state.isSavingPassword,
                                onChanged: () => setState(() {}),
                                onSubmit: _submit,
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PasswordSection extends StatelessWidget {
  final TextEditingController controller;
  final String password;
  final bool isLoading;
  final bool isSaving;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;

  const _PasswordSection({
    required this.controller,
    required this.password,
    required this.isLoading,
    required this.isSaving,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isBusy = isLoading || isSaving;
    final canSubmit = controller.text.length == 4 && !isBusy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contraseña actual',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1E1E),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        _PasswordDigits(password: password, isLoading: isLoading),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isBusy,
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: Color(0xFF1E1E1E),
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Nueva (4 dígitos)',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                    color: const Color(0xFF1E1E1E).withValues(alpha: 0.4),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E).withValues(alpha: 0.04),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: const Color(0xFF1E1E1E).withValues(alpha: 0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: const Color(0xFF1E1E1E).withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF667eea),
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (_) => onChanged(),
                onSubmitted: (_) => onSubmit(),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: canSubmit ? onSubmit : null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: canSubmit || isSaving ? 1 : 0.4,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: isSaving
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PasswordDigits extends StatelessWidget {
  final String password;
  final bool isLoading;

  const _PasswordDigits({required this.password, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF667eea),
        ),
      );
    }

    final digits = (password.isEmpty ? '----' : password)
        .padRight(4, '-')
        .substring(0, 4)
        .split('');

    return Row(
      children: digits
          .map(
            (digit) => Container(
              width: 28,
              height: 32,
              margin: const EdgeInsets.only(right: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                digit,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667eea),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
