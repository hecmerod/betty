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
    on<ReceiveSshOutput>(_onReceiveSshOutput);
    on<SshError>(_onSshError);
  }

  Future<void> _onInitializeTerminal(InitializeTerminal event, Emitter<TerminalState> emit) async {
    emit(state.copyWith(isConnecting: true));

    try {
      final sshCommand = await _sshService.startSsh();

      final newHistory = List<String>.from(state.history)
        ..add('🔌 Conectando a SSH...')
        ..add('📡 Comando: $sshCommand')
        ..add('✅ Conexión SSH establecida')
        ..add('💻 Terminal remoto listo')
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

      // Escuchar el output SSH
      _listenToSshOutput();
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

  /// Escucha el output del SSH en tiempo real
  void _listenToSshOutput() {
    _sshService.outputStream.listen(
      (output) {
        add(ReceiveSshOutput(output));
      },
      onError: (error) {
        add(SshError(error.toString()));
      },
    );
  }

  void _onReceiveSshOutput(ReceiveSshOutput event, Emitter<TerminalState> emit) {
    final newHistory = List<String>.from(state.history)..add(event.output);
    emit(state.copyWith(history: newHistory, shouldScrollToBottom: true));
  }

  void _onSshError(SshError event, Emitter<TerminalState> emit) {
    final newHistory = List<String>.from(state.history)..add('❌ Error SSH: ${event.error}');
    emit(state.copyWith(history: newHistory, shouldScrollToBottom: true));
  }

  void _onProcessCommand(ProcessCommand event, Emitter<TerminalState> emit) {
    final command = event.command.trim();

    if (command.isEmpty) {
      return;
    }

    // Si estamos conectados a SSH, enviar comando por SSH
    if (state.isConnected && _sshService.isConnected) {
      _sshService.sendInput('$command\n');

      // Añadir el comando al historial para mostrar lo que el usuario escribió
      final newHistory = List<String>.from(state.history)..add('> $command');
      emit(state.copyWith(history: newHistory, shouldScrollToBottom: true));
    } else {
      // Procesamiento local si no hay conexión SSH
      final newHistory = List<String>.from(state.history)..add('betty@fragoneta:~\$ $command');

      final response = _commandProcessor.processCommand(command);
      if (response.isNotEmpty) {
        newHistory.add(response);
      }

      emit(state.copyWith(history: newHistory, shouldScrollToBottom: true));
    }
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
