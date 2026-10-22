import 'package:betty_app/alarm/domain/camera_type.dart';

abstract class CameraPort {
  String getVideoStreamUrl({CameraType type = CameraType.internal, int? index, bool grid = false});

  Map<String, String> getVideoStreamHeaders();
}
