import 'package:flutter/material.dart';

import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../services/task_share_service.dart';
import '../../services/user_service.dart';
import '../assignment/assign_task_screen.dart';
import '../sharing/task_sharing_screen.dart';
import 'task_edit_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({
    super.key,
    required this.taskService,
    required this.shareService,
    required this.userService,
  });

  final TaskService taskService;
  final TaskShareService shareService;
  final UserService userService;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Task>> _tasks = widget.taskService.list();
  final _search = TextEditingController();
  String? _status;
  String? _priority;
  String? _scope;
  String? _sortBy;
  String _order = 'asc';

  void _reload() => setState(() => _tasks = widget.taskService.list(
        query: _search.text,
        status: _status,
        priority: _priority,
        scope: _scope,
        sortBy: _sortBy,
        order: _order,
      ));

  Future<void> _openEditor([Task? task]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TaskEditScreen(
          taskService: widget.taskService,
          task: task,
        ),
      ),
    );
    if (changed == true) _reload();
  }

  Future<void> _openDetails(Task task) async {
    final activities = await widget.taskService.activities(task.id);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(task.title),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(task.description.isEmpty ? 'Không có mô tả' : task.description),
              const SizedBox(height: 12),
              Text('Trạng thái: ${task.status}'),
              Text('Ưu tiên: ${task.priority}'),
              if (task.startDate != null) Text('Bắt đầu: ${task.startDate!.day}/${task.startDate!.month}/${task.startDate!.year}'),
              if (task.dueDate != null) Text('Hạn: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}'),
              if (task.ownerName != null) Text('Người tạo: ${task.ownerName}'),
              const SizedBox(height: 12),
              const Text('Lịch sử hoạt động', style: TextStyle(fontWeight: FontWeight.bold)),
              if (activities.isEmpty)
                const Text('Chưa có hoạt động')
              else
                ...activities.take(5).map(
                  (activity) => Text(
                    '${activity['action'] ?? 'updated'} - ${activity['createdAt'] ?? ''}',
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); _openEditor(task); }, child: const Text('Chỉnh sửa')),
          TextButton(onPressed: () { Navigator.pop(context); Navigator.of(context).push(MaterialPageRoute(builder: (_) => AssignTaskScreen(taskId: task.id, shareService: widget.shareService, userService: widget.userService))); }, child: const Text('Giao việc')),
          FilledButton(onPressed: () { Navigator.pop(context); Navigator.of(context).push(MaterialPageRoute(builder: (_) => TaskSharingScreen(taskId: task.id, shareService: widget.shareService, userService: widget.userService))); }, child: const Text('Chia sẻ')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: _tasks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: OutlinedButton(
              onPressed: _reload,
              child: const Text('Không thể tải công việc - Thử lại'),
            ),
          );
        }
        final tasks = snapshot.data ?? const <Task>[];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _search,
                onSubmitted: (_) => _reload(),
                decoration: InputDecoration(
                  labelText: 'Tìm công việc',
                  suffixIcon: IconButton(
                    onPressed: _reload,
                    icon: const Icon(Icons.search),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _filter('Phạm vi', _scope, {
                    'created': 'Của tôi',
                    'assigned': 'Được giao',
                    'shared': 'Được chia sẻ',
                  }, (value) { setState(() => _scope = value); _reload(); }),
                  _filter('Trạng thái', _status, {
                    'Pending': 'Chưa làm',
                    'InProgress': 'Đang làm',
                    'Completed': 'Hoàn thành',
                  }, (value) { setState(() => _status = value); _reload(); }),
                  _filter('Ưu tiên', _priority, {
                    'Low': 'Thấp',
                    'Medium': 'Trung bình',
                    'High': 'Cao',
                  }, (value) { setState(() => _priority = value); _reload(); }),
                  _filter('Sắp xếp', _sortBy, {
                    'dueDate': 'Hạn',
                    'priority': 'Ưu tiên',
                    'createdAt': 'Ngày tạo',
                  }, (value) { setState(() => _sortBy = value); _reload(); }),
                  IconButton(
                    tooltip: 'Đổi thứ tự',
                    onPressed: () { setState(() => _order = _order == 'asc' ? 'desc' : 'asc'); _reload(); },
                    icon: Icon(_order == 'asc' ? Icons.arrow_upward : Icons.arrow_downward),
                  ),
                ],
              ),
            ),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text('Chưa có công việc nào.'))
                  : RefreshIndicator(
                      onRefresh: () async => _reload(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                        itemCount: tasks.length,
                        itemBuilder: (_, index) => _TaskCard(
                          task: tasks[index],
                          onOpenDetail: () => _openDetails(tasks[index]),
                          onEdit: () => _openEditor(tasks[index]),
                          onAssign: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AssignTaskScreen(
                                taskId: tasks[index].id,
                                shareService: widget.shareService,
                                userService: widget.userService,
                              ),
                            ),
                          ),
                          onShare: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TaskSharingScreen(
                                taskId: tasks[index].id,
                                shareService: widget.shareService,
                                userService: widget.userService,
                              ),
                            ),
                          ),
                          onDelete: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Xóa công việc?'),
                                content: Text(tasks[index].title),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                                  FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await widget.taskService.remove(tasks[index].id);
                              _reload();
                            }
                          },
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _filter(
    String label,
    String? value,
    Map<String, String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: DropdownButton<String>(
        hint: Text(label),
        value: value,
        items: [
          DropdownMenuItem<String>(value: null, child: Text('Tất cả $label')),
          ...options.entries.map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value))),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onOpenDetail,
    required this.onEdit,
    required this.onAssign,
    required this.onShare,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onOpenDetail;
  final VoidCallback onEdit;
  final VoidCallback onAssign;
  final VoidCallback onShare;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onOpenDetail,
        title: Text(task.title),
        subtitle: Text('${task.status} • ${task.priority}\n${task.description}'),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') onEdit();
            if (value == 'assign') onAssign();
            if (value == 'share') onShare();
            if (value == 'delete') await onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
            PopupMenuItem(value: 'assign', child: Text('Giao việc')),
            PopupMenuItem(value: 'share', child: Text('Chia sẻ')),
            PopupMenuItem(value: 'delete', child: Text('Xóa')),
          ],
        ),
      ),
    );
  }
}
