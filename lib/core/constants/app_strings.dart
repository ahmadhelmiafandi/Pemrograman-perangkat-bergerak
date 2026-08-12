/// String konstan aplikasi.
class AppStrings {
  const AppStrings._();

  static const String appTitle = 'Remedial Task Tracker';
  static const String homeTitle = 'My Tasks';
  static const String addTaskTitle = 'Add Task';
  static const String editTaskTitle = 'Edit Task';
  static const String detailTitle = 'Task Detail';

  static const String fieldTitle = 'Title';
  static const String fieldTitleHint = 'e.g. Complete Math Assignment';
  static const String fieldDescription = 'Description';
  static const String fieldPriority = 'Priority';
  static const String fieldDueDate = 'Due date';
  static const String actionSave = 'Save';
  static const String actionDelete = 'Delete';
  static const String actionRetry = 'Retry';
  static const String actionEdit = 'Edit';

  static const String emptyAll = 'No tasks yet. Tap + to add one.';
  static const String emptySearch = 'No tasks match your search or filter.';
  static const String loading = 'Loading tasks...';
  static const String deleteConfirm = 'Delete this task?';

  static const String errTitleRequired = 'Title is required.';
  static const String errTitleTooShort = 'Title must be at least 3 characters.';
  static const String errDueDateInPast = 'Due date cannot be in the past.';

  // Search & Filter
  static const String searchHint = 'Search tasks by title...';
  static const String filterAll = 'All';
  static const String filterStatus = 'Status';
  static const String filterPriority = 'Priority';

  // Detail screen labels
  static const String labelDescription = 'Description';
  static const String labelPriority = 'Priority';
  static const String labelDueDate = 'Due Date';
  static const String labelStatus = 'Status';
  static const String labelCompleted = 'Completed';
  static const String labelNotCompleted = 'Not Completed';
}
