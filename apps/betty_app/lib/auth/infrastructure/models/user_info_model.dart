import '../../domain/entities/user_info.dart';

class UserInfoModel extends UserInfo {
  const UserInfoModel({
    required super.authenticated,
    super.tokenIssuedAt,
    super.tokenExpiresAt,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      authenticated: json['authenticated'] ?? false,
      tokenIssuedAt: json['tokenIssuedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['tokenIssuedAt'] * 1000)
          : null,
      tokenExpiresAt: json['tokenExpiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['tokenExpiresAt'] * 1000)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authenticated': authenticated,
      'tokenIssuedAt': tokenIssuedAt?.millisecondsSinceEpoch,
      'tokenExpiresAt': tokenExpiresAt?.millisecondsSinceEpoch,
    };
  }

  UserInfo toEntity() {
    return UserInfo(
      authenticated: authenticated,
      tokenIssuedAt: tokenIssuedAt,
      tokenExpiresAt: tokenExpiresAt,
    );
  }
}
