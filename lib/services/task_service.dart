import '../models/task.dart';
import 'api_client.dart';

class TaskService {
  TaskService(this.client);

  final ApiClient client;

  Future<List<Task>> list({
    String query = '',
    String? status,
    String? priority,
    String? scope,
    String? sortBy,
    String order = 'asc',
  }) async {
    final params = <String, String>{
      'search': ?query.trim().isEmpty ? null : query.trim(),
      'status': ?status,
      'priority': ?priority,
      'scope': ?scope,
      'sortBy': ?sortBy,
      'order': ?sortBy == null ? null : order,
    };
    final suffix = params.isEmpty
        ? ''
        : '?${params.entries.map((entry) => '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}').join('&')}';
    final data = await client.get('/tasks$suffix');
    final items = data is List ? data : (data as Map<String, dynamic>)['tasks'];
    return (items as List<dynamic>)
        .map((item) => Task.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Task> create(Map<String, dynamic> body) async =>
      Task.fromJson(await client.post('/tasks', body) as Map<String, dynamic>);

  Future<Task> update(String id, Map<String, dynamic> body) async =>
      Task.fromJson(await client.patch('/tasks/$id', body) as Map<String, dynamic>);

  Future<Task> updateStatus(String id, String status) async =>
      Task.fromJson(
        await client.patch('/tasks/$id/status', {'status': status})
            as Map<String, dynamic>,
      );

  Future<List<Map<String, dynamic>>> activities(String id) async {
    final data = await client.get('/tasks/$id/activity');
    final items = data is List ? data : (data as Map<String, dynamic>)['activities'];
    return (items as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<void> remove(String id) async {
    await client.delete('/tasks/$id');
  }
}
