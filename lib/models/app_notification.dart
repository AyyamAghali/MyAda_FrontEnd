class AppNotification {
  final String id;
  final String type;
  final String message;
  final String channel;
  final String recipientUserId;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.message,
    required this.channel,
    required this.recipientUserId,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      channel: (json['channel'] ?? '').toString(),
      recipientUserId: (json['recipientUserId'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString())
          ?.toLocal(),
    );
  }
}
