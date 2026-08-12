import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/task.dart';
import '../providers/task_provider.dart';
import 'task_form_screen.dart';

/// Layar detail task — menampilkan semua field (title, description, priority,
/// dueDate, status). Reaktif via context.watch: perubahan dari form langsung
/// terlihat di sini.
class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final task = provider.findById(taskId);

    // Task sudah dihapus — pop kembali ke list
    if (task == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop();
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.detailTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: AppStrings.actionEdit,
            onPressed: () => _openEdit(context, task),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: AppStrings.actionDelete,
            onPressed: () => _confirmDelete(context, task.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              task.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: task.isCompleted
                    ? colorScheme.onSurface.withValues(alpha: 0.5)
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Status & Priority chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip(
                  context,
                  label: task.status.name.toUpperCase(),
                  color: _statusColor(task.status),
                  icon: _statusIcon(task.status),
                ),
                _buildChip(
                  context,
                  label: task.priority.name.toUpperCase(),
                  color: _priorityColor(task.priority),
                  icon: Icons.flag,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Due Date
            _DetailRow(
              icon: Icons.event,
              label: AppStrings.labelDueDate,
              value: '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
              valueColor: task.status == TaskStatus.overdue
                  ? AppColors.statusOverdue
                  : null,
            ),
            const SizedBox(height: 12),

            // Completion status
            _DetailRow(
              icon: task.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              label: AppStrings.labelStatus,
              value: task.isCompleted
                  ? AppStrings.labelCompleted
                  : AppStrings.labelNotCompleted,
              valueColor: task.isCompleted
                  ? AppColors.statusCompleted
                  : AppColors.statusPending,
            ),
            const SizedBox(height: 24),

            // Description
            Text(
              AppStrings.labelDescription,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.description.isNotEmpty
                    ? task.description
                    : '(No description)',
                style: theme.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 32),

            // Toggle completion button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () =>
                    context.read<TaskProvider>().toggleComplete(task.id),
                icon: Icon(
                  task.isCompleted
                      ? Icons.undo
                      : Icons.check_circle_outline,
                ),
                label: Text(
                  task.isCompleted
                      ? 'Mark as Incomplete'
                      : 'Mark as Complete',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      backgroundColor: color.withValues(alpha: 0.08),
    );
  }

  IconData _statusIcon(TaskStatus s) => switch (s) {
        TaskStatus.pending => Icons.schedule,
        TaskStatus.overdue => Icons.warning_amber,
        TaskStatus.completed => Icons.check_circle,
      };

  Color _statusColor(TaskStatus s) => switch (s) {
        TaskStatus.pending => AppColors.statusPending,
        TaskStatus.overdue => AppColors.statusOverdue,
        TaskStatus.completed => AppColors.statusCompleted,
      };

  Color _priorityColor(TaskPriority p) => switch (p) {
        TaskPriority.high => AppColors.priorityHigh,
        TaskPriority.medium => AppColors.priorityMedium,
        TaskPriority.low => AppColors.priorityLow,
      };

  Future<void> _openEdit(BuildContext context, Task task) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TaskFormScreen(task: task),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: const Text(AppStrings.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.actionDelete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<TaskProvider>().deleteTask(id);
      // Task dihapus -> build akan pop otomatis karena findById == null
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: valueColor != null ? FontWeight.w600 : null,
            ),
          ),
        ),
      ],
    );
  }
}
