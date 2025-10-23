import 'package:equatable/equatable.dart';

abstract class LightsEvent extends Equatable {
  const LightsEvent();

  @override
  List<Object?> get props => [];
}

class ChangePageEvent extends LightsEvent {
  final int pageIndex;

  const ChangePageEvent(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

class ToggleExteriorLightEvent extends LightsEvent {
  final String lightType;
  final bool isOn;

  const ToggleExteriorLightEvent(this.lightType, this.isOn);

  @override
  List<Object?> get props => [lightType, isOn];
}

class ToggleInteriorLightEvent extends LightsEvent {
  final String lightType;
  final bool isOn;

  const ToggleInteriorLightEvent(this.lightType, this.isOn);

  @override
  List<Object?> get props => [lightType, isOn];
}
