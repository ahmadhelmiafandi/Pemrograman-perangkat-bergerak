import '../../domain/task.dart';
import '../local/local_task_datasource.dart';

/// Interface repositori task sebagai kontrak abstraksi antara UI/Provider dan Data Source.
abstract class TaskRepository {
  Future<List<Task>> getAll();
  Future<void> save(Task task);
  Future<void> remove(String id);
}

/// Implementasi [TaskRepository] berbasis SQLite melalui [LocalTaskDatasource].
class LocalTaskRepository implements TaskRepository {
  LocalTaskRepository(this._local);

  final LocalTaskDatasource _local;

  @override
  Future<List<Task>> getAll() => _local.getAll();

  @override
  Future<void> save(Task task) async {
    final existing = await _local.getAll();
    final exists = existing.any((t) => t.id == task.id);
    if (exists) {
      await _local.update(task);
    } else {
      await _local.insert(task);
    }
  }

  @override
  Future<void> remove(String id) => _local.delete(id);
}
