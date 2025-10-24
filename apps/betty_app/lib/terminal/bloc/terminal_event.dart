import 'package:equatable/equatable.dart';

abstract class TerminalEvent extends Equatable {
  const TerminalEvent();

  @override
  List<Object?> get props => [];
}

class InitializeTerminal extends TerminalEvent {
  const InitializeTerminal();
}

class ProcessCommand extends TerminalEvent {
  final String command;

  const ProcessCommand(this.command);

  @override
  List<Object?> get props => [command];
}

class ClearTerminal extends TerminalEvent {
  const ClearTerminal();
}

class CloseTerminal extends TerminalEvent {}

class ScrollToBottom extends TerminalEvent {}

class ReceiveSshOutput extends TerminalEvent {
  final String output;
  const ReceiveSshOutput(this.output);
}

class SshError extends TerminalEvent {
  final String error;
  const SshError(this.error);
}
