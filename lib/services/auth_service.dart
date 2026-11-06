import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this.client);

  final ApiClient client;

  Future<User> login(String email, String password) async {
    final data = await client.post('/auth/login', {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;
    client.token = data['token']?.toString();
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<User> register(
    String fullName,
    String email,
    String password,
  ) async {
    final data = await client.post('/auth/register', {
      'name': fullName,
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;
    client.token = data['token']?.toString();
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<User> me() async {
    final data = await client.get('/auth/me') as Map<String, dynamic>;
    return User.fromJson(data['user'] as Map<String, dynamic>? ?? data);
  }

  void logout() => client.token = null;
}
