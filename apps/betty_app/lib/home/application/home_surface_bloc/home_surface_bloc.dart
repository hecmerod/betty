import 'package:betty_app/home/application/home_surface_bloc/home_surface_event.dart';
import 'package:betty_app/home/application/home_surface_bloc/home_surface_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeSurfaceBloc extends Bloc<HomeSurfaceEvent, HomeSurfaceState> {
  HomeSurfaceBloc() : super(HomeSurfaceState.initial()) {
    on<ShowHomeSurface>(_onShowHomeSurface);
  }

  void _onShowHomeSurface(
    ShowHomeSurface event,
    Emitter<HomeSurfaceState> emit,
  ) {
    if (event.surface == state.surface) return;
    emit(HomeSurfaceState(event.surface));
  }
}
