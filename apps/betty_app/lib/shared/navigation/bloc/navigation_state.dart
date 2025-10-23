import 'package:equatable/equatable.dart';

class NavigationState extends Equatable {
  final Map<String?, bool> hiddenStates;
  final DateTime timestamp;
  final String? pendingRoute;
  final Object? pendingArguments;

  const NavigationState({
    required this.hiddenStates,
    required this.timestamp,
    this.pendingRoute,
    this.pendingArguments,
  });

  factory NavigationState.initial() {
    return NavigationState(
      hiddenStates: const {},
      timestamp: DateTime.now(),
      pendingRoute: null,
      pendingArguments: null,
    );
  }

  bool isHidden(String? animationId) {
    if (hiddenStates[null] == true) return true;

    return hiddenStates[animationId] ?? false;
  }

  NavigationState copyWith({
    Map<String?, bool>? hiddenStates,
    String? pendingRoute,
    Object? pendingArguments,
    bool clearPendingRoute = false,
  }) {
    return NavigationState(
      hiddenStates: hiddenStates ?? this.hiddenStates,
      timestamp: DateTime.now(),
      pendingRoute: clearPendingRoute ? null : (pendingRoute ?? this.pendingRoute),
      pendingArguments: clearPendingRoute ? null : (pendingArguments ?? this.pendingArguments),
    );
  }

  @override
  List<Object?> get props => [hiddenStates, timestamp, pendingRoute, pendingArguments];
}
