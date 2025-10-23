import 'package:equatable/equatable.dart';

abstract class TerminalEvent extends Equatable {
  const TerminalEvent();

  @override
  List<Object?> get props => [];
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

class CloseTerminal extends TerminalEvent {
  const CloseTerminal();
}

class ScrollToBottom extends TerminalEvent {
  const ScrollToBottom();
}
