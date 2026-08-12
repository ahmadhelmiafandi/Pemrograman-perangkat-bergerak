import '../../domain/task.dart';
import 'task_api_client.dart';

/// Datasource remote yang membungkus [TaskApiClient].
class RemoteTaskDatasource {
  RemoteTaskDatasource(this._client);

  final TaskApiClient _client;

  TaskApiClient get client => _client;

  Future<List<Task>> getAll() => _client.listTasks();
  Future<Task> create(Task task) => _client.createTask(task);
  Future<Task> update(Task task) => _client.updateTask(task);
  Future<void> delete(String id) => _client.deleteTask(id);
}
