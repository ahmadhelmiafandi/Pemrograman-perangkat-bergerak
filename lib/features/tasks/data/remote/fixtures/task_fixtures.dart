import '../../../domain/task.dart';

/// Data fixture offline untuk mode Mock API.
class TaskFixtures {
  const TaskFixtures._();

  /// Daftar task awal untuk mode Mock.
  static List<Task> get defaultTasks => [
        Task(
          id: 'mock-01',
          title: 'Fixture: Integrasi REST API P05',
          description: 'Mengisi endpoint mock API dan menguji data flow.',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          priority: TaskPriority.high,
        ),
        Task(
          id: 'mock-02',
          title: 'Fixture: Pengujian Error State',
          description: 'Mensimulasikan NetworkError dan Retry button.',
          dueDate: DateTime.now().add(const Duration(days: 3)),
          priority: TaskPriority.medium,
        ),
        Task(
          id: 'mock-03',
          title: 'Fixture: Dokumen Kontrak JSON',
          description: 'Memastikan fromJson dan toJson sesuai spesifikasi.',
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
          priority: TaskPriority.low,
          isCompleted: true,
        ),
      ];
}
