import 'package:flutter_test/flutter_test.dart';
import 'package:p03_provider_crud/features/tasks/data/local/task_database.dart';
import 'package:p03_provider_crud/features/tasks/data/local/task_mapper.dart';
import 'package:p03_provider_crud/features/tasks/domain/task.dart';

void main() {
  final sampleTask = Task(
    id: 't-test-1',
    title: 'Test Task',
    description: 'Mapper test description',
    dueDate: DateTime.utc(2026, 9, 1, 8, 0, 0),
    priority: TaskPriority.high,
    isCompleted: true,
  );

  group('TaskMapper Unit Tests', () {
    test('toRow menghasilkan Map kolom sesuai TaskSchema', () {
      final row = TaskMapper.toRow(sampleTask);

      expect(row[TaskSchema.columnId], 't-test-1');
      expect(row[TaskSchema.columnTitle], 'Test Task');
      expect(row[TaskSchema.columnDescription], 'Mapper test description');
      expect(row[TaskSchema.columnDueDate], '2026-09-01T08:00:00.000Z');
      expect(row[TaskSchema.columnPriority], 'high');
      expect(row[TaskSchema.columnIsCompleted], 1);
    });

    test('fromRow menghasilkan Task setara dengan data valid', () {
      final row = <String, Object?>{
        TaskSchema.columnId: 't-test-1',
        TaskSchema.columnTitle: 'Test Task',
        TaskSchema.columnDescription: 'Mapper test description',
        TaskSchema.columnDueDate: '2026-09-01T08:00:00.000Z',
        TaskSchema.columnPriority: 'high',
        TaskSchema.columnIsCompleted: 1,
      };

      final task = TaskMapper.fromRow(row);

      expect(task.id, 't-test-1');
      expect(task.title, 'Test Task');
      expect(task.description, 'Mapper test description');
      expect(task.dueDate, DateTime.utc(2026, 9, 1, 8, 0, 0));
      expect(task.priority, TaskPriority.high);
      expect(task.isCompleted, true);
    });

    test('round-trip toRow -> fromRow menjaga keutuhan data', () {
      final row = TaskMapper.toRow(sampleTask);
      final restoredTask = TaskMapper.fromRow(row);

      expect(restoredTask.id, sampleTask.id);
      expect(restoredTask.title, sampleTask.title);
      expect(restoredTask.description, sampleTask.description);
      expect(restoredTask.dueDate, sampleTask.dueDate);
      expect(restoredTask.priority, sampleTask.priority);
      expect(restoredTask.isCompleted, sampleTask.isCompleted);
    });
  });
}
