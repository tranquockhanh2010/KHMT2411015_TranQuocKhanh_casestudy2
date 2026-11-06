import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/statistics_service.dart';
import '../../services/user_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.userService,
    required this.statisticsService,
  });

  final User user;
  final VoidCallback onLogout;
  final UserService userService;
  final StatisticsService statisticsService;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(user.fullName, style: Theme.of(context).textTheme.headlineSmall),
        Text(user.email),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _editProfile(context),
          icon: const Icon(Icons.edit),
          label: const Text('Cập nhật hồ sơ'),
        ),
        OutlinedButton.icon(
          onPressed: () => _changePassword(context),
          icon: const Icon(Icons.lock),
          label: const Text('Đổi mật khẩu'),
        ),
        const SizedBox(height: 16),
        FutureBuilder<dynamic>(
          future: statisticsService.tasks(),
          builder: (_, snapshot) => Card(
            child: ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Thống kê công việc'),
              subtitle: Text(snapshot.hasError
                  ? 'Không thể tải thống kê'
                  : snapshot.connectionState == ConnectionState.waiting
                      ? 'Đang tải...'
                      : '${snapshot.data ?? 'Chưa có dữ liệu'}'),
            ),
          ),
        ),
        FutureBuilder<dynamic>(
          future: statisticsService.assignments(),
          builder: (_, snapshot) => Card(
            child: ListTile(
              leading: const Icon(Icons.assignment_ind),
              title: const Text('Phân công'),
              subtitle: Text(snapshot.hasError
                  ? 'Không thể tải dữ liệu'
                  : snapshot.connectionState == ConnectionState.waiting
                      ? 'Đang tải...'
                      : '${snapshot.data ?? 'Chưa có dữ liệu'}'),
            ),
          ),
        ),
        FutureBuilder<dynamic>(
          future: statisticsService.deadlines(),
          builder: (_, snapshot) => Card(
            child: ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Công việc theo hạn'),
              subtitle: Text(snapshot.hasError
                  ? 'Không thể tải dữ liệu'
                  : snapshot.connectionState == ConnectionState.waiting
                      ? 'Đang tải...'
                      : '${snapshot.data is List ? (snapshot.data as List).length : snapshot.data ?? 0} công việc'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: onLogout, child: const Text('Đăng xuất')),
      ],
    );
  }

  Future<void> _editProfile(BuildContext context) async {
    final name = TextEditingController(text: user.fullName);
    final email = TextEditingController(text: user.email);
    final formKey = GlobalKey<FormState>();
    final save = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cập nhật hồ sơ'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Họ tên')),
            TextFormField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Lưu')),
        ],
      ),
    );
    if (save != true || name.text.trim().isEmpty || email.text.trim().isEmpty) {
      name.dispose();
      email.dispose();
      return;
    }
    if (!context.mounted) return;
    try {
      await userService.updateProfile(name: name.text.trim(), email: email.text.trim());
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật hồ sơ')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
    name.dispose();
    email.dispose();
  }

  Future<void> _changePassword(BuildContext context) async {
    final current = TextEditingController();
    final next = TextEditingController();
    final save = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: current, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại')),
          TextField(controller: next, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu mới')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Đổi')),
        ],
      ),
    );
    if (save != true || current.text.isEmpty || next.text.length < 6) {
      current.dispose();
      next.dispose();
      return;
    }
    if (!context.mounted) return;
    try {
      await userService.changePassword(currentPassword: current.text, newPassword: next.text);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đổi mật khẩu')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
    current.dispose();
    next.dispose();
  }
}
