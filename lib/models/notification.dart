class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    this.taskId,
  });

  final String id;
  final String title;
  final String message;
  final bool isRead;
  final String? taskId;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        isRead: json['isRead'] == true || json['read'] == true,
        taskId: json['taskId']?.toString() ??
            (json['data'] is Map<String, dynamic>
                ? (json['data'] as Map<String, dynamic>)['taskId']?.toString()
                : null),
      );
}
