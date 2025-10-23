import 'package:flutter_bloc/flutter_bloc.dart';
import '../animations/animation_constants.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationState.initial()) {
    on<HideAllWidgets>(_onHideAllWidgets);
    on<ShowAllWidgets>(_onShowAllWidgets);
    on<NavigateToPage>(_onNavigateToPage);
    on<ClearPendingRoute>(_onClearPendingRoute);
  }

  void _onHideAllWidgets(HideAllWidgets event, Emitter<NavigationState> emit) {
    final newStates = <String?, bool>{null: true};
    emit(state.copyWith(hiddenStates: newStates));
  }

  void _onShowAllWidgets(ShowAllWidgets event, Emitter<NavigationState> emit) {
    final newStates = <String?, bool>{null: false};
    emit(state.copyWith(hiddenStates: newStates));
  }

  Future<void> _onNavigateToPage(NavigateToPage event, Emitter<NavigationState> emit) async {
    // Solo animar si animateWidgets es true
    if (event.animateWidgets) {
      final newStates = <String?, bool>{null: true};
      emit(state.copyWith(hiddenStates: newStates));
      await Future.delayed(kHideWidgetAnimationTotal);
    }

    emit(state.copyWith(pendingRoute: event.routeName, pendingArguments: event.arguments));
  }

  void _onClearPendingRoute(ClearPendingRoute event, Emitter<NavigationState> emit) {
    emit(state.copyWith(clearPendingRoute: true));
  }
}
