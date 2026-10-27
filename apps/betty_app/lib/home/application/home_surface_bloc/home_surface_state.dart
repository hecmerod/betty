import 'package:equatable/equatable.dart';

enum HomeSurface { dashboard, batteries, notifications }

class HomeSurfaceState extends Equatable {
  final HomeSurface surface;

  const HomeSurfaceState(this.surface);

  factory HomeSurfaceState.initial() {
    return const HomeSurfaceState(HomeSurface.dashboard);
  }

  @override
  List<Object?> get props => [surface];
}
