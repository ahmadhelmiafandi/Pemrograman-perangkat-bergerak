import 'package:flutter_test/flutter_test.dart';
import 'package:p03_provider_crud/features/tasks/domain/task.dart';
import 'package:p03_provider_crud/features/tasks/presentation/providers/task_provider.dart';

/// Test CRUD inti untuk P03.
///
/// Sebagian test di sini **SENGAJA GAGAL (merah)** karena [TaskProvider] CRUD
/// masih no-op (TODO). Target checkpoint: implementasikan add/update/delete/
/// toggle di `task_provider.dart` sampai semua test hijau. Lihat `README.md`.
void main() {
  late TaskProvider provider;

  setUp(() {
    provider = TaskProvider(
      initialTasks: [
        Task(
          id: '1',
          title: 'Task One',
          description: 'first',
          dueDate: DateTime(2026, 9, 1),
          priority: TaskPriority.medium,
        ),
        Task(
          id: '2',
          title: 'Task Two',
          description: 'second',
          dueDate: DateTime(2026, 9, 2),
          priority: TaskPriority.low,
        ),
      ],
    );
  });

  test('initial state memiliki 2 task', () {
    expect(provider.count, 2);
    expect(provider.isLoading, isFalse);
    expect(provider.error, isNull);
  });

  test('findById mengembalikan task yang benar', () {
    expect(provider.findById('1')?.title, 'Task One');
    expect(provider.findById('missing'), isNull);
  });

  test(
    'TODO(student): addTask menambah task dan memanggil notifyListeners',
    () {
      var changed = 0;
      provider.addListener(() => changed++);

      provider.addTask(
        Task(
          id: '3',
          title: 'Task Three',
          description: 'third',
          dueDate: DateTime(2026, 9, 3),
        ),
      );

      expect(provider.count, 3);
      expect(provider.findById('3'), isNotNull);
      expect(changed, greaterThan(0));
    },
  );

  test(
    'TODO(student): updateTask mengganti task dengan id sama',
    () {
      provider.updateTask(
        Task(
          id: '1',
          title: 'Task One Updated',
          description: 'first',
          dueDate: DateTime(2026, 9, 1),
        ),
      );

      expect(provider.findById('1')?.title, 'Task One Updated');
      expect(provider.count, 2);
    },
  );

  test(
    'TODO(student): deleteTask menghapus task',
    () {
      provider.deleteTask('1');
      expect(provider.count, 1);
      expect(provider.findById('1'), isNull);
    },
  );

  test(
    'TODO(student): toggleComplete membalik isCompleted',
    () {
      expect(provider.findById('1')?.isCompleted, isFalse);
      provider.toggleComplete('1');
      expect(provider.findById('1')?.isCompleted, isTrue);
      provider.toggleComplete('1');
      expect(provider.findById('1')?.isCompleted, isFalse);
    },
  );
}
