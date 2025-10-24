import 'package:betty_app/terminal/bloc/terminal_bloc.dart';
import 'package:betty_app/terminal/bloc/terminal_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TerminalHistory extends StatefulWidget {
  const TerminalHistory({super.key});

  @override
  State<TerminalHistory> createState() => _TerminalHistoryState();
}

class _TerminalHistoryState extends State<TerminalHistory> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TerminalBloc, TerminalState>(
      listenWhen: (_, current) => current.shouldScrollToBottom,
      listener: (context, state) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      },
      child: BlocBuilder<TerminalBloc, TerminalState>(
        builder: (context, state) {
          // Mostrar indicador de carga mientras se conecta
          if (state.isConnecting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea))),
                  const SizedBox(height: 24),
                  Text(
                    'Conectando al servidor SSH...',
                    style: TextStyle(
                      color: const Color(0xFF1E1E1E).withValues(alpha: 0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Por favor, espera un momento',
                    style: TextStyle(color: const Color(0xFF1E1E1E).withValues(alpha: 0.4), fontSize: 14),
                  ),
                ],
              ),
            );
          }

          if (state.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.terminal, size: 64, color: const Color(0xFF1E1E1E).withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text(
                    'Escribe "help" para ver los comandos disponibles',
                    style: TextStyle(color: const Color(0xFF1E1E1E).withValues(alpha: 0.4), fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.history.length,
            itemBuilder: (context, index) {
              final entry = state.history[index];
              final isCommand = entry.startsWith('betty@fragoneta');

              if (isCommand) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '❯',
                          style: TextStyle(color: Color(0xFF667eea), fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.replaceFirst('betty@fragoneta:~\$ ', ''),
                          style: const TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 14,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 8),
                  child: Text(
                    entry,
                    style: TextStyle(
                      color: const Color(0xFF1E1E1E).withValues(alpha: 0.7),
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
