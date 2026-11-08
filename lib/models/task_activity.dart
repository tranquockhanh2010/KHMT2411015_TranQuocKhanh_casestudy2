class TaskActivity {
  const TaskActivity({
    required this.id,
    required this.action,
    required this.createdAt,
  });

  final String id;
  final String action;
  final DateTime? createdAt;

  factory TaskActivity.fromJson(Map<String, dynamic> json) => TaskActivity(
        id: json['_id']?.toString() ?? '',
        action: json['action']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      );
}
