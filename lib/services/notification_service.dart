import '../models/notification.dart';
import 'api_client.dart';

class NotificationService {
  NotificationService(this.client);

  final ApiClient client;

  Future<List<AppNotification>> list() async {
    final data = await client.get('/notifications');
    final items = data is List ? data : (data as Map<String, dynamic>)['notifications'];
    return (items as List<dynamic>)
        .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(String id) async {
    await client.patch('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await client.patch('/notifications/read-all');
  }

  Future<int> unreadCount() async {
    final data = await client.get('/notifications/unread-count');
    return (data as Map<String, dynamic>)['count'] as int? ?? 0;
  }
}
