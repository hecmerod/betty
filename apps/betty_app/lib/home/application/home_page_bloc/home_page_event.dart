import 'package:equatable/equatable.dart';

abstract class HomePageEvent extends Equatable {
  const HomePageEvent();

  @override
  List<Object?> get props => [];
}

class PageTransitionStarted extends HomePageEvent {
  final int page;

  const PageTransitionStarted(this.page);

  @override
  List<Object?> get props => [page];
}

class PageTransitionFinished extends HomePageEvent {
  final int page;

  const PageTransitionFinished(this.page);

  @override
  List<Object?> get props => [page];
}
