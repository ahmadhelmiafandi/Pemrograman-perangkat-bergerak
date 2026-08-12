import '../../domain/task.dart';
import 'task_database.dart';

/// Mapper eksplisit antara model Dart [Task] dan baris SQLite `Map<String, Object?>`.
class TaskMapper {
  const TaskMapper._();

  /// Mengonversi objek [Task] ke baris Map SQLite.
  static Map<String, Object?> toRow(Task task) {
    return <String, Object?>{
      TaskSchema.columnId: task.id,
      TaskSchema.columnTitle: task.title,
      TaskSchema.columnDescription: task.description,
      TaskSchema.columnDueDate: task.dueDate.toIso8601String(),
      TaskSchema.columnPriority: task.priority.name,
      TaskSchema.columnIsCompleted: task.isCompleted ? 1 : 0,
    };
  }

  /// Mengonversi baris Map SQLite ke objek [Task].
  static Task fromRow(Map<String, Object?> row) {
    return Task(
      id: row[TaskSchema.columnId] as String,
      title: row[TaskSchema.columnTitle] as String,
      description: row[TaskSchema.columnDescription] as String,
      dueDate: DateTime.parse(row[TaskSchema.columnDueDate] as String),
      priority: TaskPriority.values.byName(row[TaskSchema.columnPriority] as String),
      isCompleted: (row[TaskSchema.columnIsCompleted] as int) != 0,
    );
  }
}
