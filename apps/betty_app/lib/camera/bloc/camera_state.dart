class CameraState {
  final int currentPage;

  const CameraState({this.currentPage = 0});

  CameraState copyWith({int? currentPage}) {
    return CameraState(currentPage: currentPage ?? this.currentPage);
  }
}
