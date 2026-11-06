import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class ApiException implements Exception {
  const ApiException(this.message, this.statusCode);

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    this.baseUrl = AppConstants.apiBaseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;
  String? token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> get(String path) => _send(() => _client.get(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      ));

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) =>
      _send(() => _client.post(
            Uri.parse('$baseUrl$path'),
            headers: _headers,
            body: body == null ? null : jsonEncode(body),
          ));

  Future<dynamic> put(String path, [Map<String, dynamic>? body]) =>
      _send(() => _client.put(
            Uri.parse('$baseUrl$path'),
            headers: _headers,
            body: body == null ? null : jsonEncode(body),
          ));

  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) =>
      _send(() => _client.patch(
            Uri.parse('$baseUrl$path'),
            headers: _headers,
            body: body == null ? null : jsonEncode(body),
          ));

  Future<dynamic> delete(String path) => _send(() => _client.delete(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      ));

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final response = await request();
    dynamic data;
    try {
      data = response.body.isEmpty ? null : jsonDecode(response.body);
    } on FormatException {
      data = null;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data is Map<String, dynamic>
          ? data['message']?.toString()
          : null;
      throw ApiException(
        message ?? 'Yêu cầu thất bại (${response.statusCode})',
        response.statusCode,
      );
    }
    return data;
  }
}
