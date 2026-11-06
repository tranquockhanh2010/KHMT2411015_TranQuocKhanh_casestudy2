import 'api_client.dart';

class UserService {
  UserService(this.client);

  final ApiClient client;

  Future<List<Map<String, dynamic>>> search(String query) async {
    final data = await client.get(
      '/users/search?q=${Uri.encodeQueryComponent(query)}',
    );
    return (data as List<dynamic>)
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
  }) async {
    final data = await client.patch('/auth/profile', {
      'name': name,
      'email': email,
    });
    return (data as Map<String, dynamic>)['user'] as Map<String, dynamic>;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await client.patch('/auth/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
