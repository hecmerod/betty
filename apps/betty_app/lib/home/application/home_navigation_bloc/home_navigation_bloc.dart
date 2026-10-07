import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_event.dart';
import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeNavigationBloc extends Bloc<HomeNavigationEvent, HomeNavigationState> {
  HomeNavigationBloc() : super(HomeNavigationState.initial()) {
    on<ScrollToPage>(_onScrollToPage);
  }

  void _onScrollToPage(ScrollToPage event, Emitter<HomeNavigationState> emit) {
    emit(state.copyWith(route: event.routeName));
  }
}
