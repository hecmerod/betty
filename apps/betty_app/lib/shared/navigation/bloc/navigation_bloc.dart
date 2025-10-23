import 'package:betty_app/shared/navigation/animations/visibility_animation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    emit(state.copyWith(hiddenStates: newStates, excludedIds: event.excludeIds));
  }

  void _onShowAllWidgets(ShowAllWidgets event, Emitter<NavigationState> emit) {
    final newStates = <String?, bool>{null: false};
    emit(state.copyWith(hiddenStates: newStates, excludedIds: []));
  }

  Future<void> _onNavigateToPage(NavigateToPage event, Emitter<NavigationState> emit) async {
    // Solo animar si animateWidgets es true
    if (event.animateWidgets) {
      final newStates = <String?, bool>{null: true};
      emit(state.copyWith(hiddenStates: newStates, excludedIds: event.excludeAnimationIds));
      await Future.delayed(kHideWidgetAnimationDuration);
    }

    emit(state.copyWith(pendingRoute: event.routeName, pendingArguments: event.arguments));
  }

  void _onClearPendingRoute(ClearPendingRoute event, Emitter<NavigationState> emit) {
    emit(state.copyWith(clearPendingRoute: true));
  }
}
