import 'package:flutter_bloc/flutter_bloc.dart';
import 'lights_event.dart';
import 'lights_state.dart';

class LightsBloc extends Bloc<LightsEvent, LightsState> {
  LightsBloc() : super(const LightsState()) {
    on<ChangePageEvent>(_onChangePage);
    on<ToggleExteriorLightEvent>(_onToggleExteriorLight);
    on<ToggleInteriorLightEvent>(_onToggleInteriorLight);
  }

  void _onChangePage(ChangePageEvent event, Emitter<LightsState> emit) {
    if (event.pageIndex == state.currentPage) return;

    emit(state.copyWith(currentPage: event.pageIndex, shouldAnimate: true));

    // Reset shouldAnimate flag
    emit(state.copyWith(shouldAnimate: false));
  }

  void _onToggleExteriorLight(ToggleExteriorLightEvent event, Emitter<LightsState> emit) {
    switch (event.lightType) {
      case 'headlights':
        emit(state.copyWith(headlightsOn: event.isOn));
        break;
      case 'rearLights':
        emit(state.copyWith(rearLightsOn: event.isOn));
        break;
      case 'emergency':
        emit(state.copyWith(emergencyLightsOn: event.isOn));
        break;
      case 'fog':
        emit(state.copyWith(fogLightsOn: event.isOn));
        break;
    }
  }

  void _onToggleInteriorLight(ToggleInteriorLightEvent event, Emitter<LightsState> emit) {
    switch (event.lightType) {
      case 'ceiling':
        emit(state.copyWith(ceilingLightsOn: event.isOn));
        break;
      case 'reading':
        emit(state.copyWith(readingLightsOn: event.isOn));
        break;
      case 'ambient':
        emit(state.copyWith(ambientLightsOn: event.isOn));
        break;
      case 'work':
        emit(state.copyWith(workLightsOn: event.isOn));
        break;
    }
  }
}
