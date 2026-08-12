import '../../../../core/errors/api_error.dart';
import '../../domain/task.dart';
import '../local/local_task_datasource.dart';
import '../remote/mock_task_api_client.dart';
import '../remote/remote_task_datasource.dart';
import 'task_repository.dart';

/// Repository koordinator Offline-First yang menggabungkan [LocalTaskDatasource]
/// (SQLite sebagai Local Source of Truth) dan [RemoteTaskDatasource] (REST API / Mock).
///
/// Strategi:
/// - Operasi tulis ([save] & [remove]) selalu berhasil pada SQLite lokal terlebih dahulu.
/// - Operasi dikirimkan ke remote secara best-effort. Jika remote gagal (network error / 5xx),
///   error ditangkap tanpa menggagalkan operasi lokal dan mengubah status [isOffline].
class OfflineFirstTaskRepository implements TaskRepository {
  OfflineFirstTaskRepository({
    required LocalTaskDatasource local,
    required RemoteTaskDatasource remote,
  })  : _local = local,
        _remote = remote;

  final LocalTaskDatasource _local;
  final RemoteTaskDatasource _remote;

  bool _isOffline = false;

  /// Menandakan apakah koneksi remote terakhir terputus/mengalami error.
  bool get isOffline => _isOffline;

  /// Membalik simulasi error jaringan khusus untuk mode Mock.
  void toggleSimulateNetworkError() {
    final client = _remote.client;
    if (client is MockTaskApiClient) {
      client.simulateNetworkError = !client.simulateNetworkError;
    }
  }

  @override
  Future<List<Task>> getAll() async {
    // 1. Baca dari SQLite lokal (pasti cepat & offline-ready)
    final localTasks = await _local.getAll();

    // 2. Coba sync dengan remote
    try {
      final remoteTasks = await _remote.getAll();
      _isOffline = false;

      // Masukkan task remote baru ke SQLite lokal jika belum ada
      for (final remoteTask in remoteTasks) {
        await _local.insert(remoteTask);
      }
      return await _local.getAll();
    } catch (e) {
      _isOffline = true;
      // Jika remote gagal, kembalikan data SQLite lokal yang ada
      return localTasks;
    }
  }

  @override
  Future<void> save(Task task) async {
    // 1. Tulis ke SQLite lokal (Local Source of Truth)
    final existing = await _local.getAll();
    final exists = existing.any((t) => t.id == task.id);
    if (exists) {
      await _local.update(task);
    } else {
      await _local.insert(task);
    }

    // 2. Coba kirim ke Remote API (best-effort)
    try {
      if (exists) {
        await _remote.update(task);
      } else {
        await _remote.create(task);
      }
      _isOffline = false;
    } on ApiError catch (_) {
      _isOffline = true;
      // Error remote ditangkap agar simpan lokal tetap sukses
    } catch (_) {
      _isOffline = true;
    }
  }

  @override
  Future<void> remove(String id) async {
    // 1. Hapus dari SQLite lokal
    await _local.delete(id);

    // 2. Coba hapus di Remote API
    try {
      await _remote.delete(id);
      _isOffline = false;
    } on ApiError catch (_) {
      _isOffline = true;
    } catch (_) {
      _isOffline = true;
    }
  }
}
