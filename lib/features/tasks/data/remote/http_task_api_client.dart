import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/errors/api_error.dart';
import '../../domain/task.dart';
import 'api_config.dart';
import 'task_api_client.dart';

/// Implementasi [TaskApiClient] berbasis HTTP untuk REST API server nyata.
class HttpTaskApiClient implements TaskApiClient {
  HttpTaskApiClient({
    http.Client? client,
    String? baseUrl,
    String? token,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _token = token ?? ApiConfig.token;

  final http.Client _client;
  final String _baseUrl;
  final String _token;

  Map<String, String> get _headers => <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token.isNotEmpty) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(ApiConfig.timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      throw mapResponseToError(response.statusCode);
    } on ApiError {
      rethrow;
    } catch (e) {
      throw NetworkError('Network error: $e');
    }
  }

  @override
  Future<List<Task>> listTasks() async {
    final response = await _send(() => _client.get(_uri('/tasks'), headers: _headers));
    try {
      final decoded = jsonDecode(response.body);
      final List<dynamic> list = decoded is List ? decoded : (decoded['data'] as List? ?? []);
      return list.map((item) => Task.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw const ParseError('Gagal mem-parse daftar task dari server.');
    }
  }

  @override
  Future<Task> createTask(Task task) async {
    final response = await _send(() => _client.post(
          _uri('/tasks'),
          headers: _headers,
          body: jsonEncode(task.toJson()),
        ));
    try {
      final decoded = jsonDecode(response.body);
      final data = decoded is Map<String, dynamic> && decoded.containsKey('data')
          ? decoded['data'] as Map<String, dynamic>
          : decoded as Map<String, dynamic>;
      return Task.fromJson(data);
    } catch (e) {
      throw const ParseError('Gagal mem-parse response pembuatan task.');
    }
  }

  @override
  Future<Task> updateTask(Task task) async {
    final response = await _send(() => _client.patch(
          _uri('/tasks/${task.id}'),
          headers: _headers,
          body: jsonEncode(task.toJson()),
        ));
    try {
      final decoded = jsonDecode(response.body);
      final data = decoded is Map<String, dynamic> && decoded.containsKey('data')
          ? decoded['data'] as Map<String, dynamic>
          : decoded as Map<String, dynamic>;
      return Task.fromJson(data);
    } catch (e) {
      throw const ParseError('Gagal mem-parse response update task.');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    await _send(() => _client.delete(_uri('/tasks/$id'), headers: _headers));
  }
}
