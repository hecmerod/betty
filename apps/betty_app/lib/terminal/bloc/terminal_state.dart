import 'package:equatable/equatable.dart';

class TerminalState extends Equatable {
  final List<String> history;
  final bool shouldClose;
  final bool shouldScrollToBottom;
  final bool isConnecting;
  final bool isConnected;
  final String? sshCommand;
  final String? errorMessage;

  const TerminalState({
    this.history = const [],
    this.shouldClose = false,
    this.shouldScrollToBottom = false,
    this.isConnecting = false,
    this.isConnected = false,
    this.sshCommand,
    this.errorMessage,
  });

  TerminalState copyWith({
    List<String>? history,
    bool? shouldClose,
    bool? shouldScrollToBottom,
    bool? isConnecting,
    bool? isConnected,
    String? sshCommand,
    String? errorMessage,
  }) {
    return TerminalState(
      history: history ?? this.history,
      shouldClose: shouldClose ?? this.shouldClose,
      shouldScrollToBottom: shouldScrollToBottom ?? this.shouldScrollToBottom,
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
      sshCommand: sshCommand ?? this.sshCommand,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    history,
    shouldClose,
    shouldScrollToBottom,
    isConnecting,
    isConnected,
    sshCommand,
    errorMessage,
  ];
}
