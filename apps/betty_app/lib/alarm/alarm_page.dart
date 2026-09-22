import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../shared/widgets/secondary_page_app_bar.dart';
import 'bloc/alarm_bloc.dart';
import 'bloc/alarm_event.dart';
import 'bloc/alarm_state.dart';
import 'widgets/alarm_main_button.dart';
import 'widgets/alarm_password_card.dart';
import 'widgets/sensor_list.dart';

class AlarmPage extends StatelessWidget {
  const AlarmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AlarmBloc()
        ..add(const LoadAlarmStatus())
        ..add(const LoadAlarmPassword())
        ..add(const LoadSensors()),
      child: const AlarmPageView(),
    );
  }
}

class AlarmPageView extends StatelessWidget {
  const AlarmPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AlarmBloc, AlarmState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        final message = state.successMessage ?? state.errorMessage;
        if (message == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: state.successMessage != null
                  ? const Color(0xFF43e97b)
                  : const Color(0xFFee5a6f),
            ),
          );
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: const SecondaryPageAppBar(title: 'Alarma'),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),
                const AlarmMainButton(),
                const SizedBox(height: 24),
                const AlarmPasswordCard(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'SENSORES',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const SensorList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
