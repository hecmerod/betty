import '../../domain/entities/protected_data.dart';
import 'user_info_model.dart';

class ProtectedDataModel extends ProtectedData {
  const ProtectedDataModel({
    required super.message,
    required super.timestamp,
    required super.user,
    required super.server,
  });

  factory ProtectedDataModel.fromJson(Map<String, dynamic> json) {
    return ProtectedDataModel(
      message: json['message'] ?? '',
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      user: UserInfoModel.fromJson(json['user'] ?? {}),
      server: json['server'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'user': (user as UserInfoModel).toJson(),
      'server': server,
    };
  }

  ProtectedData toEntity() {
    return ProtectedData(
      message: message,
      timestamp: timestamp,
      user: user,
      server: server,
    );
  }
}
