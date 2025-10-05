import 'user_info.dart';

class ProtectedData {
  final String message;
  final DateTime timestamp;
  final UserInfo user;
  final String server;

  const ProtectedData({
    required this.message,
    required this.timestamp,
    required this.user,
    required this.server,
  });

  bool get isAuthenticated => user.authenticated;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProtectedData &&
        other.message == message &&
        other.timestamp == timestamp &&
        other.user == user &&
        other.server == server;
  }

  @override
  int get hashCode =>
      message.hashCode ^ timestamp.hashCode ^ user.hashCode ^ server.hashCode;

  @override
  String toString() =>
      'ProtectedData(message: $message, timestamp: $timestamp, user: $user, server: $server)';
}
