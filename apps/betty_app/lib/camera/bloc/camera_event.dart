abstract class CameraEvent {
  const CameraEvent();
}

class ChangePageEvent extends CameraEvent {
  final int page;
  const ChangePageEvent(this.page);
}

class SelectCameraIndexEvent extends CameraEvent {
  final int? cameraIndex;
  const SelectCameraIndexEvent(this.cameraIndex);
}
