import 'package:betty_app/home/application/home_surface_bloc/home_surface_state.dart';
import 'package:equatable/equatable.dart';

abstract class HomeSurfaceEvent extends Equatable {
  const HomeSurfaceEvent();

  @override
  List<Object?> get props => [];
}

class ShowHomeSurface extends HomeSurfaceEvent {
  final HomeSurface surface;

  const ShowHomeSurface(this.surface);

  @override
  List<Object?> get props => [surface];
}
