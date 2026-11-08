import 'package:flutter/material.dart';
import '../../services/task_share_service.dart';
import '../../services/user_service.dart';

class AssignTaskScreen extends StatelessWidget {
  const AssignTaskScreen({
    super.key,
    required this.taskId,
    required this.shareService,
    required this.userService,
  });

  final String taskId;
  final TaskShareService shareService;
  final UserService userService;

  @override
  Widget build(BuildContext context) => _AssignmentView(
        taskId: taskId,
        shareService: shareService,
        userService: userService,
      );
}

class _AssignmentView extends StatefulWidget {
  const _AssignmentView({
    required this.taskId,
    required this.shareService,
    required this.userService,
  });
  final String taskId;
  final TaskShareService shareService;
  final UserService userService;

  @override
  State<_AssignmentView> createState() => _AssignmentViewState();
}

class _AssignmentViewState extends State<_AssignmentView> {
  final _email = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.shareService.list(widget.taskId);
    if (!mounted) return;
    setState(() => _items = (data is List ? data : (data['shares'] as List? ?? const [])).cast<Map<String, dynamic>>());
  }

  Future<void> _assign() async {
    if (_email.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await widget.shareService.share(widget.taskId, emails: [_email.text.trim()], role: 'editor');
      _email.clear();
      await _load();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Giao công việc')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _email,
              decoration: InputDecoration(
                labelText: 'Email người phụ trách',
                suffixIcon: IconButton(onPressed: _busy ? null : _assign, icon: const Icon(Icons.add)),
              ),
              onSubmitted: (_) => _assign(),
            ),
            const SizedBox(height: 16),
            ..._items.map((item) {
              final user = item['user'] is Map ? item['user'] as Map : const {};
              final id = user['_id']?.toString() ?? item['userId']?.toString() ?? '';
              return ListTile(
                title: Text(user['name']?.toString() ?? user['email']?.toString() ?? id),
                subtitle: Text(item['role']?.toString() ?? 'editor'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () async {
                    await widget.shareService.revoke(widget.taskId, id);
                    _load();
                  },
                ),
              );
            }),
          ],
        ),
      );

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }
}
