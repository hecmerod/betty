import 'package:betty_app/core/navigation/presentation/routes.dart';
import 'package:equatable/equatable.dart';

class HomeNavigationState extends Equatable {
  final String route;

  const HomeNavigationState({required this.route});

  factory HomeNavigationState.initial() {
    return const HomeNavigationState(route: Routes.home);
  }

  HomeNavigationState copyWith({String? pendingRoute, String? route}) {
    return HomeNavigationState(route: route ?? this.route);
  }

  @override
  List<Object?> get props => [route];
}
