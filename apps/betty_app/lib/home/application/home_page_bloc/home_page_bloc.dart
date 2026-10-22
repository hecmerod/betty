import 'package:betty_app/home/application/home_page_bloc/home_page_event.dart';
import 'package:betty_app/home/application/home_page_bloc/home_page_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  HomePageBloc() : super(HomePageState.initial()) {
    on<PageTransitionStarted>(_onPageTransitionStarted);
    on<PageTransitionFinished>(_onPageTransitionFinished);
  }

  void _onPageTransitionStarted(PageTransitionStarted event, Emitter<HomePageState> emit) {
    if (event.page == state.page) return;

    emit(state.copyWith(page: event.page, clearActivePage: true));
  }

  void _onPageTransitionFinished(PageTransitionFinished event, Emitter<HomePageState> emit) {
    if (event.page != state.page) return;

    emit(state.copyWith(activePage: event.page));
  }
}
