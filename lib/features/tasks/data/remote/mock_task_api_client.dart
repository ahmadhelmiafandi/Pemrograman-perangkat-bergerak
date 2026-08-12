import '../../../../core/errors/api_error.dart';
import '../../domain/task.dart';
import 'fixtures/task_fixtures.dart';
import 'task_api_client.dart';

/// Implementasi in-memory [TaskApiClient] untuk mode Mock (tanpa server).
class MockTaskApiClient implements TaskApiClient {
  MockTaskApiClient({
    List<Task>? initialTasks,
    this.simulateNetworkError = false,
  }) : _tasks = initialTasks != null
            ? List<Task>.from(initialTasks)
            : List<Task>.from(TaskFixtures.defaultTasks);

  final List<Task> _tasks;

  /// Flag simulasi error jaringan untuk pengujian UI error & retry.
  bool simulateNetworkError;

  void _checkNetworkError() {
    if (simulateNetworkError) {
      throw const NetworkError('Network Error (Mock): Koneksi terputus.');
    }
  }

  @override
  Future<List<Task>> listTasks() async {
    _checkNetworkError();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_tasks);
  }

  @override
  Future<Task> createTask(Task task) async {
    _checkNetworkError();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (_tasks.any((t) => t.id == task.id)) {
      throw const ClientError(409, 'Conflict (409): ID task sudah ada.');
    }
    _tasks.add(task);
    return task;
  }

  @override
  Future<Task> updateTask(Task task) async {
    _checkNetworkError();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      throw const NotFoundError('Task tidak ditemukan untuk di-update (404).');
    }
    _tasks[index] = task;
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    _checkNetworkError();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw const NotFoundError('Task tidak ditemukan untuk dihapus (404).');
    }
    _tasks.removeAt(index);
  }
}
