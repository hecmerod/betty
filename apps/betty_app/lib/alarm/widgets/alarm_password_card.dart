import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/alarm_bloc.dart';
import '../bloc/alarm_event.dart';
import '../bloc/alarm_state.dart';

class AlarmPasswordCard extends StatefulWidget {
  const AlarmPasswordCard({super.key});

  @override
  State<AlarmPasswordCard> createState() => _AlarmPasswordCardState();
}

class _AlarmPasswordCardState extends State<AlarmPasswordCard> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
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
      listener: (context, state) {
        _controller.clear();
      },
      child: BlocBuilder<AlarmBloc, AlarmState>(
        builder: (context, state) {
          final isBusy = state.isLoadingPassword || state.isSavingPassword;
          final canSubmit = _controller.text.length == 4 && !isBusy;

          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF1E1E1E).withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF667eea,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: Color(0xFF667eea),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
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
                              _PasswordDigits(
                                password: state.password,
                                isLoading: state.isLoadingPassword,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            enabled: !isBusy,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
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
                                color: const Color(
                                  0xFF1E1E1E,
                                ).withValues(alpha: 0.4),
                              ),
                              filled: true,
                              fillColor: const Color(
                                0xFF1E1E1E,
                              ).withValues(alpha: 0.04),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: const Color(
                                    0xFF1E1E1E,
                                  ).withValues(alpha: 0.1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: const Color(
                                    0xFF1E1E1E,
                                  ).withValues(alpha: 0.1),
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
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) => _submit(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: canSubmit ? () => _submit(context) : null,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 150),
                            opacity: canSubmit || state.isSavingPassword
                                ? 1
                                : 0.4,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: state.isSavingPassword
                                  ? const Padding(
                                      padding: EdgeInsets.all(14),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PasswordDigits extends StatelessWidget {
  final String? password;
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

    final digits = (password ?? '----')
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
                  letterSpacing: 0,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
