abstract class CameraEvent {
  const CameraEvent();
}

class ChangePageEvent extends CameraEvent {
  final int page;
  const ChangePageEvent(this.page);
}
