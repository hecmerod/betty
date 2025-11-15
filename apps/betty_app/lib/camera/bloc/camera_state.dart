class CameraState {
  final int currentPage;
  final int? selectedCameraIndex;

  const CameraState({this.currentPage = 0, this.selectedCameraIndex});

  CameraState copyWith({int? currentPage, int? selectedCameraIndex}) {
    return CameraState(
      currentPage: currentPage ?? this.currentPage,
      selectedCameraIndex: selectedCameraIndex ?? this.selectedCameraIndex,
    );
  }

  CameraState clearCameraIndex() {
    return CameraState(currentPage: currentPage, selectedCameraIndex: null);
  }
}
