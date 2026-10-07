import 'package:equatable/equatable.dart';

class NavigationState extends Equatable {
  final Map<String?, bool> hiddenStates;
  final List<String> excludedIds;
  final DateTime timestamp;
  final String? pendingRoute;
  final Object? pendingArguments;

  const NavigationState({
    required this.hiddenStates,
    this.excludedIds = const [],
    required this.timestamp,
    this.pendingRoute,
    this.pendingArguments,
  });

  factory NavigationState.initial() {
    return NavigationState(
      hiddenStates: const {},
      excludedIds: const [],
      timestamp: DateTime.now(),
      pendingRoute: null,
      pendingArguments: null,
    );
  }

  bool isHidden(String? animationId) {
    // Si el ID está en la lista de excluidos, no se oculta
    if (animationId != null && excludedIds.contains(animationId)) {
      return false;
    }

    if (hiddenStates[null] == true) return true;

    return hiddenStates[animationId] ?? false;
  }

  NavigationState copyWith({
    Map<String?, bool>? hiddenStates,
    List<String>? excludedIds,
    String? pendingRoute,
    Object? pendingArguments,
    bool clearPendingRoute = false,
  }) {
    return NavigationState(
      hiddenStates: hiddenStates ?? this.hiddenStates,
      excludedIds: excludedIds ?? this.excludedIds,
      timestamp: DateTime.now(),
      pendingRoute: clearPendingRoute ? null : (pendingRoute ?? this.pendingRoute),
      pendingArguments: clearPendingRoute ? null : (pendingArguments ?? this.pendingArguments),
    );
  }

  @override
  List<Object?> get props => [hiddenStates, excludedIds, timestamp, pendingRoute, pendingArguments];
}
