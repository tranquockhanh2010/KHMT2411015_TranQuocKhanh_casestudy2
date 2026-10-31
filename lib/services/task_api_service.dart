import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/task.dart';

class TaskApiService {
  const TaskApiService({
    this.baseUrl = 'http://10.0.2.2:3000/api',
  });

  final String baseUrl;

  Future<List<Task>> getTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks'));

    if (response.statusCode != 200) {
      throw Exception(
        'Không thể tải danh sách công việc (${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('API trả về dữ liệu không hợp lệ');
    }

    return decoded
        .map((json) => Task.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

