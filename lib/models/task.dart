class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.createdBy,
    this.assigneeIds = const [],
    this.primaryAssigneeId,
    this.ownerName,
    this.startDate,
    this.dueDate,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String? createdBy;
  final List<String> assigneeIds;
  final String? primaryAssigneeId;
  final String? ownerName;
  final DateTime? startDate;
  final DateTime? dueDate;

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      priority: json['priority']?.toString() ?? 'Medium',
      status: json['status']?.toString() ?? 'Pending',
      createdBy: json['createdBy']?.toString(),
      assigneeIds: (json['assigneeIds'] as List<dynamic>? ?? [])
          .map((id) => id.toString())
          .toList(),
      primaryAssigneeId: json['primaryAssigneeId']?.toString(),
      ownerName: json['owner'] is Map<String, dynamic>
          ? (json['owner'] as Map<String, dynamic>)['name']?.toString()
          : null,
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? ''),
      dueDate: DateTime.tryParse(json['dueDate']?.toString() ?? ''),
    );
  }
}
