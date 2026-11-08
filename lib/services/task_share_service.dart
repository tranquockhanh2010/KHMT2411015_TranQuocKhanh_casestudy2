import 'api_client.dart';

class TaskShareService {
  TaskShareService(this.client);

  final ApiClient client;

  Future<dynamic> list(String taskId) => client.get('/tasks/$taskId/shares');

  Future<dynamic> share(
    String taskId, {
    required List<String> emails,
    String role = 'viewer',
  }) =>
      client.post('/tasks/$taskId/shares', {
        'emails': emails,
        'role': role,
      });

  Future<dynamic> update(
    String taskId,
    String userId, {
    String? role,
    bool? primary,
  }) =>
      client.patch('/tasks/$taskId/shares/$userId', {
        'role': ?role,
        'primary': ?primary,
      });

  Future<void> revoke(String taskId, String userId) async {
    await client.delete('/tasks/$taskId/shares/$userId');
  }
}
