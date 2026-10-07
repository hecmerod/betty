import 'dart:convert';

class NotificationModel {
  final String id;
  final String? title;
  final String? body;
  final DateTime receivedAt;
  final Map<String, dynamic>? data;
  final bool read;

  NotificationModel({required this.id, this.title, this.body, required this.receivedAt, this.data, this.read = false});

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? receivedAt,
    Map<String, dynamic>? data,
    bool? read,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      data: data ?? this.data,
      read: read ?? this.read,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'receivedAt': receivedAt.millisecondsSinceEpoch,
      'data': data != null ? jsonEncode(data) : null,
      'read': read ? 1 : 0,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      title: map['title'] as String?,
      body: map['body'] as String?,
      receivedAt: DateTime.fromMillisecondsSinceEpoch(map['receivedAt'] as int),
      data: map['data'] != null ? jsonDecode(map['data'] as String) as Map<String, dynamic> : null,
      read: (map['read'] as int) == 1,
    );
  }
}
