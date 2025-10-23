import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class HideAllWidgets extends NavigationEvent {
  const HideAllWidgets();
}

class ShowAllWidgets extends NavigationEvent {
  const ShowAllWidgets();
}

class NavigateToPage extends NavigationEvent {
  final String routeName;
  final Object? arguments;
  final bool animateWidgets;

  const NavigateToPage(this.routeName, {this.arguments, this.animateWidgets = true});

  @override
  List<Object?> get props => [routeName, arguments, animateWidgets];
}

class ClearPendingRoute extends NavigationEvent {
  const ClearPendingRoute();
}
