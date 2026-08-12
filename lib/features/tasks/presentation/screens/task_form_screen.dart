import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/task.dart';
import '../providers/task_provider.dart';

/// Form tambah/edit task.
///
/// Validasi:
/// - Title: wajib diisi, minimal 3 karakter.
/// - Due date: tidak boleh di masa lalu saat mode tambah (boleh saat edit).
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.task});

  /// Bukan null berarti mode edit.
  final Task? task;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskPriority _priority;
  late DateTime _dueDate;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descriptionController = TextEditingController(text: t?.description ?? '');
    _priority = t?.priority ?? TaskPriority.medium;
    _dueDate = t?.dueDate ?? DateTime.now().add(const Duration(days: 3));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return AppStrings.errTitleRequired;
    if (text.length < 3) return AppStrings.errTitleTooShort;
    return null;
  }

  /// Validasi due date: tidak boleh di masa lalu saat mode tambah.
  /// Saat mode edit, masa lalu diperbolehkan.
  String? _validateDueDate() {
    if (!_isEditing) {
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      final selected = DateTime(_dueDate.year, _dueDate.month, _dueDate.day);
      if (selected.isBefore(today)) {
        return AppStrings.errDueDateInPast;
      }
    }
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Validasi due date terpisah (karena bukan TextFormField)
    final dueDateError = _validateDueDate();
    if (dueDateError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dueDateError),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final task = Task(
      id: widget.task?.id ??
          'task-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _dueDate,
      priority: _priority,
      isCompleted: widget.task?.isCompleted ?? false,
    );

    final provider = context.read<TaskProvider>();
    if (_isEditing) {
      provider.updateTask(task);
    } else {
      provider.addTask(task);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dueDateError = _validateDueDate();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editTaskTitle : AppStrings.addTaskTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: AppStrings.fieldTitle,
                hintText: AppStrings.fieldTitleHint,
                border: OutlineInputBorder(),
              ),
              validator: _validateTitle,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: AppStrings.fieldDescription,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(AppStrings.fieldPriority),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<TaskPriority>(
                    initialValue: _priority,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: TaskPriority.values
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.name.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _priority = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(AppStrings.fieldDueDate),
              subtitle: Text(
                '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                style: dueDateError != null
                    ? TextStyle(color: theme.colorScheme.error)
                    : null,
              ),
              trailing: const Icon(Icons.event),
              onTap: _pickDate,
            ),
            // Tampilkan pesan error due date jika ada
            if (dueDateError != null)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  dueDateError,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: const Text(AppStrings.actionSave),
            ),
          ],
        ),
      ),
    );
  }
}
