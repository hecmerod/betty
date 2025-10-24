import 'package:betty_app/terminal/widgets/terminal_header.dart';
import 'package:betty_app/terminal/widgets/terminal_history.dart';
import 'package:betty_app/terminal/widgets/terminal_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'bloc/terminal_bloc.dart';
import 'bloc/terminal_event.dart';
import 'bloc/terminal_state.dart';

class TerminalPage extends StatefulWidget {
  const TerminalPage({super.key});

  @override
  State<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends State<TerminalPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final terminalHeight = screenHeight * 0.6 + 300;

    return BlocProvider(
      create: (context) {
        final bloc = TerminalBloc();
        bloc.add(const InitializeTerminal());
        return bloc;
      },
      child: Builder(
        builder: (context) {
          return BlocListener<TerminalBloc, TerminalState>(
            listenWhen: (_, current) => current.shouldClose && mounted,
            listener: (context, state) {
              Navigator.of(context).pop();
            },
            child: PopScope(
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) {
                  context.read<TerminalBloc>().add(CloseTerminal());
                }
                await _animationController.reverse();
              },
              child: Scaffold(
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: false,
                body: Align(
                  alignment: Alignment.bottomCenter,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut)),
                      child: RepaintBoundary(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              height: terminalHeight,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                                border: Border.all(color: const Color(0xFF1E1E1E).withValues(alpha: 0.1), width: 1.5),
                              ),
                              child: Column(
                                children: [
                                  const TerminalHeader(),
                                  Expanded(child: RepaintBoundary(child: const TerminalHistory())),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                    child: RepaintBoundary(child: const TerminalInput()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
