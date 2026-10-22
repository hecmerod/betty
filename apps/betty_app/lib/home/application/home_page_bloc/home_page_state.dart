import 'package:equatable/equatable.dart';

class HomePageState extends Equatable {
  static const int initialPage = 1;

  final int page;
  final int? activePage;

  const HomePageState({required this.page, required this.activePage});

  factory HomePageState.initial() {
    return const HomePageState(page: initialPage, activePage: initialPage);
  }

  HomePageState copyWith({int? page, int? activePage, bool clearActivePage = false}) {
    return HomePageState(
      page: page ?? this.page,
      activePage: clearActivePage ? null : (activePage ?? this.activePage),
    );
  }

  @override
  List<Object?> get props => [page, activePage];
}
