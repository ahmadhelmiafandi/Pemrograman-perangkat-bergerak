import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_error.dart';
import '../../data/repositories/offline_first_task_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/task.dart';

/// State manajemen task dengan [ChangeNotifier].
///
/// Mendukung penyimpanan persisten (SQLite/REST API) via [TaskRepository] serta
/// penanganan error state UI terstruktur.
class TaskProvider extends ChangeNotifier {
  TaskProvider({
    TaskRepository? repository,
    List<Task> initialTasks = const [],
  })  : _repo = repository,
        _tasks = initialTasks;

  final TaskRepository? _repo;

  List<Task> _tasks;
  bool _isLoading = false;
  String? _error;

  // --- Search & Filter state (Assignment 1) ---
  String _searchQuery = '';
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get count => _tasks.length;

  /// Menandakan apakah repository berada dalam mode offline / lokal-only.
  bool get isOfflineMode {
    final repo = _repo;
    if (repo is OfflineFirstTaskRepository) {
      return repo.isOffline;
    }
    return false;
  }

  /// Membalik simulasi error jaringan (khusus mode Mock) dan memuat ulang task.
  Future<void> toggleSimulateNetworkError() async {
    final repo = _repo;
    if (repo is OfflineFirstTaskRepository) {
      repo.toggleSimulateNetworkError();
      await loadTasks();
    }
  }

  // --- Search & Filter getters ---
  String get searchQuery => _searchQuery;
  TaskStatus? get activeStatusFilter => _statusFilter;
  TaskPriority? get activePriorityFilter => _priorityFilter;

  /// Filtered tasks: AND logic antara search query, status filter, dan priority filter.
  List<Task> get filteredTasks {
    var result = List<Task>.from(_tasks);

    // Search by title, case-insensitive
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((t) => t.title.toLowerCase().contains(query)).toList();
    }

    // Filter by status
    if (_statusFilter != null) {
      result = result.where((t) => t.status == _statusFilter).toList();
    }

    // Filter by priority
    if (_priorityFilter != null) {
      result = result.where((t) => t.priority == _priorityFilter).toList();
    }

    return List.unmodifiable(result);
  }

  Task? findById(String id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Memuat data dari repositori dengan penanganan [ApiError].
  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_repo != null) {
        _tasks = await _repo.getAll();
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        _tasks = Task.getDummyTasks();
      }
    } on ApiError catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- CRUD persisten -------------------------------------------------------

  /// Menambahkan task baru ke repositori dan menyegarkan state.
  Future<void> addTask(Task task) async {
    _error = null;
    try {
      if (_repo != null) {
        await _repo.save(task);
        await loadTasks();
      } else {
        _tasks = [..._tasks, task];
        notifyListeners();
      }
    } on ApiError catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add task: $e';
      notifyListeners();
    }
  }

  /// Memperbarui task yang sudah ada di repositori dan menyegarkan state.
  Future<void> updateTask(Task task) async {
    _error = null;
    try {
      if (_repo != null) {
        await _repo.save(task);
        await loadTasks();
      } else {
        _tasks = [
          for (final t in _tasks)
            if (t.id == task.id) task else t,
        ];
        notifyListeners();
      }
    } on ApiError catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update task: $e';
      notifyListeners();
    }
  }

  /// Menghapus task berdasarkan [id] dari repositori.
  Future<void> deleteTask(String id) async {
    _error = null;
    try {
      if (_repo != null) {
        await _repo.remove(id);
        await loadTasks();
      } else {
        _tasks = _tasks.where((t) => t.id != id).toList();
        notifyListeners();
      }
    } on ApiError catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete task: $e';
      notifyListeners();
    }
  }

  /// Toggle status selesai task dengan [id].
  Future<void> toggleComplete(String id) async {
    final task = findById(id);
    if (task == null) return;
    _error = null;
    try {
      if (_repo != null) {
        await _repo.save(task.copyWith(isCompleted: !task.isCompleted));
        await loadTasks();
      } else {
        _tasks = [
          for (final t in _tasks)
            if (t.id == id) t.copyWith(isCompleted: !t.isCompleted) else t,
        ];
        notifyListeners();
      }
    } on ApiError catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle task completion: $e';
      notifyListeners();
    }
  }

  // ---- Search & Filter setters ---------------------------------------------

  /// Set search query. Case-insensitive, reaktif saat mengetik.
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  /// Set filter status. null = all (tidak difilter).
  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  /// Set filter priority. null = all (tidak difilter).
  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  /// Bersihkan semua filter dan search.
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _priorityFilter = null;
    notifyListeners();
  }
}
