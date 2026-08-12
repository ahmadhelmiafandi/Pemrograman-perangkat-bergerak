import 'package:flutter_test/flutter_test.dart';
import 'package:p03_provider_crud/features/tasks/data/local/local_task_datasource.dart';
import 'package:p03_provider_crud/features/tasks/data/local/task_database.dart';
import 'package:p03_provider_crud/features/tasks/domain/task.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late TaskDatabase database;
  late LocalTaskDatasource datasource;

  setUp(() async {
    database = TaskDatabase(fileName: inMemoryDatabasePath);
    datasource = LocalTaskDatasource(database);
    await datasource.clear();
  });

  final task1 = Task(
    id: 't-01',
    title: 'Alpha Task',
    description: 'First test task',
    dueDate: DateTime.utc(2026, 9, 1),
    priority: TaskPriority.high,
  );

  final task2 = Task(
    id: 't-02',
    title: 'Beta Task',
    description: 'Second test task',
    dueDate: DateTime.utc(2026, 9, 2),
    priority: TaskPriority.low,
    isCompleted: true,
  );

  group('LocalTaskDatasource Integration Tests (FFI)', () {
    test('getAll mengembalikan list kosong pada tabel awal', () async {
      final tasks = await datasource.getAll();
      expect(tasks, isEmpty);
    });

    test('insert menambah task ke SQLite', () async {
      await datasource.insert(task1);
      final tasks = await datasource.getAll();

      expect(tasks.length, 1);
      expect(tasks.first.id, 't-01');
      expect(tasks.first.title, 'Alpha Task');
    });

    test('update memperbarui task yang ada di SQLite', () async {
      await datasource.insert(task1);
      final updatedTask = task1.copyWith(title: 'Alpha Task Updated', isCompleted: true);

      await datasource.update(updatedTask);
      final tasks = await datasource.getAll();

      expect(tasks.length, 1);
      expect(tasks.first.title, 'Alpha Task Updated');
      expect(tasks.first.isCompleted, true);
    });

    test('delete menghapus task dari SQLite berdasarkan ID', () async {
      await datasource.insert(task1);
      await datasource.insert(task2);

      var tasks = await datasource.getAll();
      expect(tasks.length, 2);

      await datasource.delete('t-01');
      tasks = await datasource.getAll();

      expect(tasks.length, 1);
      expect(tasks.first.id, 't-02');
    });

    test('clear menghapus seluruh task dari SQLite', () async {
      await datasource.insert(task1);
      await datasource.insert(task2);

      await datasource.clear();
      final tasks = await datasource.getAll();

      expect(tasks, isEmpty);
    });
  });
}
