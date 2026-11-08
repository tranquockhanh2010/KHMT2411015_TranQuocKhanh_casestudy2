import 'package:flutter/material.dart';
import '../../services/task_share_service.dart';
import '../../services/user_service.dart';

class TaskSharingScreen extends StatelessWidget {
  const TaskSharingScreen({
    super.key,
    required this.taskId,
    required this.shareService,
    required this.userService,
  });

  final String taskId;
  final TaskShareService shareService;
  final UserService userService;

  @override
  Widget build(BuildContext context) {
    return _SharingView(
      taskId: taskId,
      shareService: shareService,
      userService: userService,
    );
  }
}

class _SharingView extends StatefulWidget {
  const _SharingView({required this.taskId, required this.shareService, required this.userService});
  final String taskId;
  final TaskShareService shareService;
  final UserService userService;
  @override
  State<_SharingView> createState() => _SharingViewState();
}

class _SharingViewState extends State<_SharingView> {
  final _email = TextEditingController();
  String _role = 'viewer';
  List<Map<String, dynamic>> _shares = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.shareService.list(widget.taskId);
    if (mounted) setState(() => _shares = (data is List ? data : (data['shares'] as List? ?? const [])).cast<Map<String, dynamic>>());
  }

  Future<void> _add() async {
    if (_email.text.trim().isEmpty) return;
    try {
      await widget.shareService.share(widget.taskId, emails: [_email.text.trim()], role: _role);
      _email.clear();
      _load();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Chia sẻ công việc')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email người nhận')),
            DropdownButton<String>(
              value: _role,
              items: const [
                DropdownMenuItem(value: 'viewer', child: Text('Chỉ xem')),
                DropdownMenuItem(value: 'editor', child: Text('Có thể chỉnh sửa')),
              ],
              onChanged: (value) => setState(() => _role = value!),
            ),
            FilledButton.icon(onPressed: _add, icon: const Icon(Icons.share), label: const Text('Chia sẻ')),
            ..._shares.map((share) {
              final user = share['user'] is Map ? share['user'] as Map : const {};
              final id = user['_id']?.toString() ?? share['userId']?.toString() ?? '';
              return ListTile(
                title: Text(user['name']?.toString() ?? user['email']?.toString() ?? id),
                subtitle: Text(share['role']?.toString() ?? 'viewer'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'revoke') {
                      await widget.shareService.revoke(widget.taskId, id);
                    } else {
                      await widget.shareService.update(widget.taskId, id, role: value);
                    }
                    _load();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'viewer', child: Text('Viewer')),
                    PopupMenuItem(value: 'editor', child: Text('Editor')),
                    PopupMenuItem(value: 'revoke', child: Text('Thu hồi')),
                  ],
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
