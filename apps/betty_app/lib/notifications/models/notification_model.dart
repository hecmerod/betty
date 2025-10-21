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
}
