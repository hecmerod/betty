import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/command_processor.dart';
import '../services/ssh_service.dart';
import 'terminal_event.dart';
import 'terminal_state.dart';

class TerminalBloc extends Bloc<TerminalEvent, TerminalState> {
  final CommandProcessor _commandProcessor = CommandProcessor();
  final SshService _sshService = SshService.instance;

  TerminalBloc() : super(const TerminalState()) {
    on<InitializeTerminal>(_onInitializeTerminal);
    on<ProcessCommand>(_onProcessCommand);
    on<ClearTerminal>(_onClearTerminal);
    on<CloseTerminal>(_onCloseTerminal);
    on<ScrollToBottom>(_onScrollToBottom);
  }

  Future<void> _onInitializeTerminal(InitializeTerminal event, Emitter<TerminalState> emit) async {
    emit(state.copyWith(isConnecting: true));

    try {
      final sshCommand = await _sshService.startSsh();

      final newHistory = List<String>.from(state.history)
        ..add('Conectando a SSH...')
        ..add('Comando: $sshCommand')
        ..add('');

      emit(
        state.copyWith(
          history: newHistory,
          isConnecting: false,
          isConnected: true,
          sshCommand: sshCommand,
          shouldScrollToBottom: true,
        ),
      );
    } catch (e) {
      final newHistory = List<String>.from(state.history)
        ..add('❌ Error al conectar: $e')
        ..add('');

      emit(
        state.copyWith(
          history: newHistory,
          isConnecting: false,
          isConnected: false,
          errorMessage: e.toString(),
          shouldScrollToBottom: true,
        ),
      );
    }
  }

  void _onProcessCommand(ProcessCommand event, Emitter<TerminalState> emit) {
    final command = event.command.trim();

    if (command.isEmpty) {
      return;
    }

    final newHistory = List<String>.from(state.history)..add('betty@fragoneta:~\$ $command');

    final response = _commandProcessor.processCommand(command);
    if (response.isNotEmpty) {
      newHistory.add(response);
    }

    emit(state.copyWith(history: newHistory, shouldScrollToBottom: true));
  }

  void _onClearTerminal(ClearTerminal event, Emitter<TerminalState> emit) {
    emit(state.copyWith(history: []));
  }

  void _onCloseTerminal(CloseTerminal event, Emitter<TerminalState> emit) {
    try {
      _sshService.stopSsh();
      emit(state.copyWith(shouldClose: true));
    } catch (e) {
      emit(state.copyWith(shouldClose: true));
    }
  }

  void _onScrollToBottom(ScrollToBottom event, Emitter<TerminalState> emit) {
    emit(state.copyWith(shouldScrollToBottom: false));
  }

  @override
  Future<void> close() async {
    try {
      await _sshService.stopSsh();
    } catch (e) {
      // Ignorar errores al cerrar
    }
    return super.close();
  }
}
