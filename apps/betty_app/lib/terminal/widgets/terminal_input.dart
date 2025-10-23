import 'package:betty_app/terminal/bloc/terminal_bloc.dart';
import 'package:betty_app/terminal/bloc/terminal_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TerminalInput extends StatefulWidget {
  const TerminalInput({super.key});

  @override
  State<TerminalInput> createState() => _TerminalInputState();
}

class _TerminalInputState extends State<TerminalInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    final command = _textController.text.trim();
    _textController.clear();

    if (command.isEmpty) return;

    if (command.toLowerCase() == 'clear') {
      context.read<TerminalBloc>().add(const ClearTerminal());
    } else {
      context.read<TerminalBloc>().add(ProcessCommand(command));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withValues(alpha: 0.1),
        border: Border(top: BorderSide(color: const Color(0xFF1E1E1E).withValues(alpha: 0.1), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '❯',
              style: TextStyle(color: Color(0xFF667eea), fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                style: const TextStyle(color: Color(0xFF1E1E1E), fontSize: 16, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: 'Escribe un comando...',
                  hintStyle: TextStyle(
                    color: const Color(0xFF1E1E1E).withValues(alpha: 0.4),
                    fontSize: 16,
                    fontFamily: 'monospace',
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSubmit(context),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Color(0xFF667eea)),
              onPressed: () => _handleSubmit(context),
            ),
          ),
        ],
      ),
    );
  }
}
