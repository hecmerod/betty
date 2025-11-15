import 'package:flutter_bloc/flutter_bloc.dart';
import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc() : super(const CameraState()) {
    on<ChangePageEvent>(_onChangePage);
    on<SelectCameraIndexEvent>(_onSelectCameraIndex);
  }

  void _onChangePage(ChangePageEvent event, Emitter<CameraState> emit) {
    emit(state.copyWith(currentPage: event.page));
  }

  void _onSelectCameraIndex(SelectCameraIndexEvent event, Emitter<CameraState> emit) {
    // Si se selecciona el mismo índice, deseleccionar (volver a null/grid)
    if (state.selectedCameraIndex == event.cameraIndex) {
      emit(state.clearCameraIndex());
    } else {
      emit(state.copyWith(selectedCameraIndex: event.cameraIndex));
    }
  }
}
