import 'package:flutter/material.dart';

import '../../models/notification.dart';
import '../../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key, required this.service});

  final NotificationService service;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<AppNotification>> _future = widget.service.list();

  void _reload() => setState(() => _future = widget.service.list());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppNotification>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: OutlinedButton(
              onPressed: _reload,
              child: const Text('Không thể tải thông báo - Thử lại'),
            ),
          );
        }
        final notifications = snapshot.data ?? const <AppNotification>[];
        if (notifications.isEmpty) {
          return const Center(child: Text('Không có thông báo mới.'));
        }
        return Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  await widget.service.markAllRead();
                  _reload();
                },
                icon: const Icon(Icons.done_all),
                label: const Text('Đánh dấu tất cả đã đọc'),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (_, index) {
                  final item = notifications[index];
                  return ListTile(
                    tileColor: item.isRead ? null : Colors.indigo.withValues(alpha: .08),
                    leading: Icon(item.isRead
                        ? Icons.notifications_none
                        : Icons.notifications_active),
                    title: Text(item.title),
                    subtitle: Text(item.message),
                    onTap: () async {
                      if (!item.isRead) await widget.service.markRead(item.id);
                      _reload();
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
