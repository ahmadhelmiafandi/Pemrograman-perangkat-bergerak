/// Prioritas tugas.
enum TaskPriority { low, medium, high }

/// Status tugas. [Task.status] dihitung dari [Task.isCompleted] dan
/// [Task.dueDate] relatif terhadap waktu sekarang.
enum TaskStatus { pending, overdue, completed }

/// Model tugas. Immutable; gunakan [copyWith] untuk perubahan.
///
/// Field diseragamkan antar starter P01–P03 agar progres saling melanjutkan.
class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool isCompleted;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
  });

  /// Status turunan. Komputasi ini harus konsisten dengan UI filter.
  TaskStatus get status {
    if (isCompleted) return TaskStatus.completed;
    final now = DateTime.now();
    if (dueDate.isBefore(now)) return TaskStatus.overdue;
    return TaskStatus.pending;
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Task && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Task(id: $id, title: $title, priority: $priority, status: $status)';

  /// Data dummy seragam (>=20 task) untuk keperluan demo dan diagnosis.
  /// Tanggal dihitung relatif terhadap [now] agar overdue/pending stabil
  /// saat aplikasi dijalankan.
  static List<Task> getDummyTasks({DateTime? now}) {
    final base = now ?? DateTime.now();
    return [
      Task(
        id: 't01',
        title: 'Complete Math Assignment',
        description: 'Finish calculus homework chapter 4.',
        dueDate: base.add(const Duration(days: 2)),
        priority: TaskPriority.high,
      ),
      Task(
        id: 't02',
        title: 'Read History Chapter 3',
        description: 'Summarize key events for the quiz.',
        dueDate: base.add(const Duration(days: 5)),
        priority: TaskPriority.medium,
      ),
      Task(
        id: 't03',
        title: 'Physics Lab Report',
        description: 'Write pendulum experiment analysis.',
        dueDate: base.subtract(const Duration(days: 1)),
        priority: TaskPriority.high,
      ),
      Task(
        id: 't04',
        title: 'Submit English Essay',
        description: 'Final draft on climate change.',
        dueDate: base.add(const Duration(days: 7)),
        priority: TaskPriority.medium,
        isCompleted: true,
      ),
      Task(
        id: 't05',
        title: 'Biology Diagrams',
        description: 'Draw cell structure and label parts.',
        dueDate: base.subtract(const Duration(days: 3)),
        priority: TaskPriority.low,
        isCompleted: true,
      ),
      Task(
        id: 't06',
        title: 'Programming Project Milestone',
        description: 'CRUD screen with validation.',
        dueDate: base.add(const Duration(days: 10)),
        priority: TaskPriority.high,
      ),
      Task(
        id: 't07',
        title: 'Design Mockup Review',
        description: 'Iterate on dashboard layout.',
        dueDate: base.add(const Duration(days: 1)),
        priority: TaskPriority.medium,
      ),
      Task(
        id: 't08',
        title: 'Chemistry Problem Set',
        description: 'Solve stoichiometry exercises 1–10.',
        dueDate: base.subtract(const Duration(days: 2)),
        priority: TaskPriority.medium,
      ),
      Task(
        id: 't09',
        title: 'Library Book Return',
        description: 'Due at the circulation desk.',
        dueDate: base.add(const Duration(days: 4)),
        priority: TaskPriority.low,
      ),
      Task(
        id: 't10',
        title: 'Group Meeting Notes',
        description: 'Compile action items from standup.',
        dueDate: base.add(const Duration(days: 3)),
        priority: TaskPriority.low,
        isCompleted: true,
      ),
      Task(
        id: 't11',
        title: 'Math Practice Sheet',
        description: 'Extra integration problems.',
        dueDate: base.add(const Duration(days: 6)),
        priority: TaskPriority.medium,
      ),
      Task(
        id: 't12',
        title: 'History Documentary Notes',
        description: 'Watch and annotate the Cold War video.',
        dueDate: base.add(const Duration(days: 8)),
        priority: TaskPriority.low,
      ),
      Task(
        id: 't13',
        title: 'Physics Quiz Prep',
        description: 'Review kinematics formulas.',
        dueDate: base.subtract(const Duration(days: 4)),
        priority: TaskPriority.high,
      ),
      Task(
        id: 't14',
        title: 'English Vocabulary Cards',
        description: 'Prepare 20 new flashcards.',
        dueDate: base.add(const Duration(days: 9)),
        priority: TaskPriority.low,
      ),
      Task(
        id: 't15',
        title: 'Biology Lab Cleanup',
        description: 'Return equipment to storage.',
        dueDate: base.subtract(const Duration(days: 5)),
        priority: TaskPriority.low,
        isCompleted: true,
      ),
      Task(
        id: 't16',
        title: 'Programming Code Review',
        description: 'Review peer pull request.',
        dueDate: base.add(const Duration(days: 11)),
        priority: TaskPriority.medium,
      ),
      Task(
        id: 't17',
        title: 'Design System Tokens',
        description: 'Document spacing and color tokens.',
        dueDate: base.add(const Duration(days: 12)),
        priority: TaskPriority.low,
      ),
      Task(
        id: 't18',
        title: 'Chemistry Lab Safety Quiz',
        description: 'Complete online safety module.',
        dueDate: base.subtract(const Duration(days: 6)),
        priority: TaskPriority.high,
      ),
      Task(
        id: 't19',
        title: 'Library Database Search',
        description: 'Find three peer-reviewed sources.',
        dueDate: base.add(const Duration(days: 13)),
        priority: TaskPriority.medium,
      ),
      Task(
        id: 't20',
        title: 'Group Presentation Slides',
        description: 'Finalize speaker notes.',
        dueDate: base.add(const Duration(days: 14)),
        priority: TaskPriority.high,
      ),
    ];
  }
}
