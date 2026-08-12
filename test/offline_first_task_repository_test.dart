import 'package:flutter_test/flutter_test.dart';
import 'package:p03_provider_crud/features/tasks/data/local/local_task_datasource.dart';
import 'package:p03_provider_crud/features/tasks/data/local/task_database.dart';
import 'package:p03_provider_crud/features/tasks/data/remote/mock_task_api_client.dart';
import 'package:p03_provider_crud/features/tasks/data/remote/remote_task_datasource.dart';
import 'package:p03_provider_crud/features/tasks/data/repositories/offline_first_task_repository.dart';
import 'package:p03_provider_crud/features/tasks/domain/task.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late TaskDatabase localDb;
  late LocalTaskDatasource localDs;
  late MockTaskApiClient mockClient;
  late RemoteTaskDatasource remoteDs;
  late OfflineFirstTaskRepository repo;

  setUp(() async {
    localDb = TaskDatabase(fileName: inMemoryDatabasePath);
    localDs = LocalTaskDatasource(localDb);
    await localDs.clear();

    mockClient = MockTaskApiClient(initialTasks: []);
    remoteDs = RemoteTaskDatasource(mockClient);

    repo = OfflineFirstTaskRepository(local: localDs, remote: remoteDs);
  });

  group('OfflineFirstTaskRepository Unit Tests', () {
    test('save menyimpan ke SQLite lokal dan remote saat koneksi normal', () async {
      final task = Task(
        id: 'offline-01',
        title: 'Offline First Task',
        description: 'Testing offline first',
        dueDate: DateTime.utc(2026, 9, 1),
      );

      await repo.save(task);

      final localTasks = await localDs.getAll();
      final remoteTasks = await remoteDs.getAll();

      expect(localTasks.length, 1);
      expect(remoteTasks.length, 1);
      expect(repo.isOffline, isFalse);
    });

    test('save tetap sukses di SQLite lokal walau remote melempar NetworkError', () async {
      mockClient.simulateNetworkError = true;

      final task = Task(
        id: 'offline-02',
        title: 'Network Error Task',
        description: 'Should persist locally',
        dueDate: DateTime.utc(2026, 9, 2),
      );

      await repo.save(task);

      final localTasks = await localDs.getAll();

      expect(localTasks.length, 1);
      expect(localTasks.first.title, 'Network Error Task');
      expect(repo.isOffline, isTrue);
    });
  });
}
