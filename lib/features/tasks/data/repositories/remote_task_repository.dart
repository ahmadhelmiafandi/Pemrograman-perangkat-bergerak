import '../../domain/task.dart';
import '../remote/remote_task_datasource.dart';
import 'task_repository.dart';

/// Implementasi [TaskRepository] berbasis remote (REST API / Mock).
class RemoteTaskRepository implements TaskRepository {
  RemoteTaskRepository(this._remote);

  final RemoteTaskDatasource _remote;

  @override
  Future<List<Task>> getAll() => _remote.getAll();

  @override
  Future<void> save(Task task) async {
    final existing = await _remote.getAll();
    final exists = existing.any((t) => t.id == task.id);
    if (exists) {
      await _remote.update(task);
    } else {
      await _remote.create(task);
    }
  }

  @override
  Future<void> remove(String id) => _remote.delete(id);
}
