import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SearchBar(
              hintText: AppStrings.searchHint,
              leading: const Icon(Icons.search),
              trailing: [
                if (provider.searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () =>
                        context.read<TaskProvider>().setSearchQuery(''),
                  ),
              ],
              onChanged: (value) =>
                  context.read<TaskProvider>().setSearchQuery(value),
              elevation: WidgetStateProperty.all(0),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Filter chips
          _FilterBar(provider: provider),
          // Task list / empty / loading / error
          Expanded(child: _body(context, provider)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, TaskProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return _ErrorView(
        message: provider.error!,
        onRetry: () => context.read<TaskProvider>().loadTasks(),
      );
    }
    if (provider.tasks.isEmpty) {
      return const Center(child: Text(AppStrings.emptyAll));
    }

    final filteredTasks = provider.filteredTasks;

    // Hasil filter/search kosong -> pesan khusus
    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            const Text(AppStrings.emptySearch),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<TaskProvider>().clearFilters(),
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }

    // Responsive: LayoutBuilder untuk portrait (1 kolom) vs landscape (2 kolom)
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        if (isWide) {
          // Landscape / tablet: grid 2 kolom
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.8,
            ),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) =>
                _buildTaskItem(context, filteredTasks[index]),
          );
        }

        // Portrait: list 1 kolom
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: filteredTasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) =>
              _buildTaskItem(context, filteredTasks[index]),
        );
      },
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: Theme.of(context).colorScheme.errorContainer,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete,
            color: Theme.of(context).colorScheme.onErrorContainer),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) =>
          context.read<TaskProvider>().deleteTask(task.id),
      child: TaskCard(
        task: task,
        onTap: () => _openDetail(context, task),
        onToggle: () =>
            context.read<TaskProvider>().toggleComplete(task.id),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {Task? task}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TaskFormScreen(task: task),
      ),
    );
  }

  Future<void> _openDetail(BuildContext context, Task task) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TaskDetailScreen(taskId: task.id),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
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
  }
}

/// Filter bar: status filter + priority filter menggunakan SegmentedButton/FilterChip.
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.provider});
  final TaskProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Status filter
          const Text('Status: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 4),
          _FilterChipItem(
            label: AppStrings.filterAll,
            selected: provider.activeStatusFilter == null,
            onSelected: () =>
                context.read<TaskProvider>().setStatusFilter(null),
          ),
          const SizedBox(width: 4),
          ...TaskStatus.values.map(
            (s) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _FilterChipItem(
                label: s.name[0].toUpperCase() + s.name.substring(1),
                selected: provider.activeStatusFilter == s,
                color: _statusColor(s),
                onSelected: () =>
                    context.read<TaskProvider>().setStatusFilter(s),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Priority filter
          const Text('Priority: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 4),
          _FilterChipItem(
            label: AppStrings.filterAll,
            selected: provider.activePriorityFilter == null,
            onSelected: () =>
                context.read<TaskProvider>().setPriorityFilter(null),
          ),
          const SizedBox(width: 4),
          ...TaskPriority.values.map(
            (p) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _FilterChipItem(
                label: p.name[0].toUpperCase() + p.name.substring(1),
                selected: provider.activePriorityFilter == p,
                color: _priorityColor(p),
                onSelected: () =>
                    context.read<TaskProvider>().setPriorityFilter(p),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: selected ? Colors.white : color,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedColor: color ?? Theme.of(context).colorScheme.primary,
      checkmarkColor: Colors.white,
      onSelected: (_) => onSelected(),
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text(AppStrings.actionRetry),
            ),
          ],
        ),
      ),
    );
  }
}
