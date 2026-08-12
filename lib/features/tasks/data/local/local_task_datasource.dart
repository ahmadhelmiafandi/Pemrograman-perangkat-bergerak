import 'package:sqflite/sqflite.dart';

import '../../domain/task.dart';
import 'task_database.dart';
import 'task_mapper.dart';

/// Datasource lokal untuk operasi CRUD SQLite pada tabel tasks.
class LocalTaskDatasource {
  LocalTaskDatasource(this._db);

  final TaskDatabase _db;

  /// Mengambil seluruh baris task dari SQLite, terurut berdasarkan judul (ASC).
  Future<List<Task>> getAll() async {
    final db = await _db.database();
    final rows = await db.query(
      TaskSchema.table,
      orderBy: '${TaskSchema.columnTitle} ASC',
    );
    return [for (final row in rows) TaskMapper.fromRow(row)];
  }

  /// Menambah task baru ke SQLite (replace jika ID sudah ada).
  Future<void> insert(Task task) async {
    final db = await _db.database();
    await db.insert(
      TaskSchema.table,
      TaskMapper.toRow(task),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Memperbarui task yang ada di SQLite berdasarkan ID.
  Future<void> update(Task task) async {
    final db = await _db.database();
    await db.update(
      TaskSchema.table,
      TaskMapper.toRow(task),
      where: '${TaskSchema.columnId} = ?',
      whereArgs: [task.id],
    );
  }

  /// Menghapus task dari SQLite berdasarkan ID.
  Future<void> delete(String id) async {
    final db = await _db.database();
    await db.delete(
      TaskSchema.table,
      where: '${TaskSchema.columnId} = ?',
      whereArgs: [id],
    );
  }

  /// Menghapus seluruh task dari tabel.
  Future<void> clear() async {
    final db = await _db.database();
    await db.delete(TaskSchema.table);
  }
}
