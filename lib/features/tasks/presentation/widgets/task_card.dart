import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/task.dart';

/// Kartu task reusable untuk P03. Mendukung tap (detail) dan toggle complete.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
  });

  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              // Toggle checkbox
              IconButton(
                icon: Icon(
                  task.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: task.isCompleted
                      ? AppColors.statusCompleted
                      : AppColors.statusPending,
                ),
                onPressed: onToggle,
              ),
              // Title + description + due date
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: task.isCompleted
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                              : null,
                          color: task.isCompleted
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          task.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      // Due date + chips row
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event,
                                size: 14,
                                color: task.status == TaskStatus.overdue
                                    ? AppColors.statusOverdue
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: task.status == TaskStatus.overdue
                                      ? AppColors.statusOverdue
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          _Chip(
                            label: task.priority.name.toUpperCase(),
                            color: _priorityColor(task.priority),
                          ),
                          _Chip(
                            label: task.status.name.toUpperCase(),
                            color: _statusColor(task.status),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Chevron
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(TaskPriority p) => switch (p) {
        TaskPriority.high => AppColors.priorityHigh,
        TaskPriority.medium => AppColors.priorityMedium,
        TaskPriority.low => AppColors.priorityLow,
      };

  Color _statusColor(TaskStatus s) => switch (s) {
        TaskStatus.pending => AppColors.statusPending,
        TaskStatus.overdue => AppColors.statusOverdue,
        TaskStatus.completed => AppColors.statusCompleted,
      };
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
