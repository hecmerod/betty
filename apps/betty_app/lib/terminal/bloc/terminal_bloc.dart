import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/command_processor.dart';
import 'terminal_event.dart';
import 'terminal_state.dart';

class TerminalBloc extends Bloc<TerminalEvent, TerminalState> {
  final CommandProcessor _commandProcessor = CommandProcessor();

  TerminalBloc() : super(const TerminalState()) {
    on<ProcessCommand>(_onProcessCommand);
    on<ClearTerminal>(_onClearTerminal);
    on<CloseTerminal>(_onCloseTerminal);
    on<ScrollToBottom>(_onScrollToBottom);
  }

  void _onProcessCommand(ProcessCommand event, Emitter<TerminalState> emit) {
    final command = event.command.trim();

    if (command.isEmpty) {
      return;
    }

    // Add command to history
    final newHistory = List<String>.from(state.history)..add('betty@fragoneta:~\$ $command');

    // Process command using service
    final response = _commandProcessor.processCommand(command);
    if (response.isNotEmpty) {
      newHistory.add(response);
    }

    emit(state.copyWith(history: newHistory, shouldScrollToBottom: true));
  }

  void _onClearTerminal(ClearTerminal event, Emitter<TerminalState> emit) {
    emit(const TerminalState(history: []));
  }

  void _onCloseTerminal(CloseTerminal event, Emitter<TerminalState> emit) {
    emit(state.copyWith(shouldClose: true));
  }

  void _onScrollToBottom(ScrollToBottom event, Emitter<TerminalState> emit) {
    emit(state.copyWith(shouldScrollToBottom: false));
  }
}
