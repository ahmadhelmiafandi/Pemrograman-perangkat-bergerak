import '../../domain/task.dart';

/// Interface abstrak untuk klien API Task Tracker.
abstract class TaskApiClient {
  /// Mengambil seluruh daftar task dari remote/mock server.
  Future<List<Task>> listTasks();

  /// Membuat task baru di remote/mock server.
  Future<Task> createTask(Task task);

  /// Memperbarui task yang ada di remote/mock server.
  Future<Task> updateTask(Task task);

  /// Menghapus task berdasarkan [id] di remote/mock server.
  Future<void> deleteTask(String id);
}
