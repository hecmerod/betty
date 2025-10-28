import 'package:flutter_bloc/flutter_bloc.dart';
import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc() : super(const CameraState()) {
    on<ChangePageEvent>(_onChangePage);
  }

  void _onChangePage(ChangePageEvent event, Emitter<CameraState> emit) {
    emit(state.copyWith(currentPage: event.page));
  }
}
