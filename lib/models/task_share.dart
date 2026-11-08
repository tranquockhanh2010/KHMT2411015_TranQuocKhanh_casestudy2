class TaskShare {
  const TaskShare({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.permission,
  });

  final String id;
  final String taskId;
  final String userId;
  final String permission;

  factory TaskShare.fromJson(Map<String, dynamic> json) => TaskShare(
        id: json['_id']?.toString() ?? '',
        taskId: json['task']?.toString() ?? json['taskId']?.toString() ?? '',
        userId: json['user']?.toString() ?? json['userId']?.toString() ?? '',
        permission: json['role']?.toString() ??
            json['permission']?.toString() ??
            'viewer',
      );
}
