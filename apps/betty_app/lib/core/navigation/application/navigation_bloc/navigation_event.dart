import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class HideAllWidgets extends NavigationEvent {
  final List<String> excludeIds;

  const HideAllWidgets({this.excludeIds = const []});

  @override
  List<Object?> get props => [excludeIds];
}

class ShowAllWidgets extends NavigationEvent {
  const ShowAllWidgets();
}

class NavigateToPage extends NavigationEvent {
  final String routeName;
  final Object? arguments;
  final bool animateWidgets;
  final List<String> excludeAnimationIds;

  const NavigateToPage(
    this.routeName, {
    this.arguments,
    this.animateWidgets = true,
    this.excludeAnimationIds = const [],
  });

  @override
  List<Object?> get props => [routeName, arguments, animateWidgets, excludeAnimationIds];
}

class ClearPendingRoute extends NavigationEvent {
  const ClearPendingRoute();
}
