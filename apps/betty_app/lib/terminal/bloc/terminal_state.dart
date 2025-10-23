import 'package:equatable/equatable.dart';

class TerminalState extends Equatable {
  final List<String> history;
  final bool shouldClose;
  final bool shouldScrollToBottom;

  const TerminalState({this.history = const [], this.shouldClose = false, this.shouldScrollToBottom = false});

  TerminalState copyWith({List<String>? history, bool? shouldClose, bool? shouldScrollToBottom}) {
    return TerminalState(
      history: history ?? this.history,
      shouldClose: shouldClose ?? this.shouldClose,
      shouldScrollToBottom: shouldScrollToBottom ?? this.shouldScrollToBottom,
    );
  }

  @override
  List<Object?> get props => [history, shouldClose, shouldScrollToBottom];
}
