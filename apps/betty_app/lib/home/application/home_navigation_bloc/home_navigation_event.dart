import 'package:equatable/equatable.dart';

abstract class HomeNavigationEvent extends Equatable {
  const HomeNavigationEvent();

  @override
  List<Object?> get props => [];
}

class ScrollToPage extends HomeNavigationEvent {
  final String routeName;

  const ScrollToPage(this.routeName);

  @override
  List<Object?> get props => [routeName];
}
