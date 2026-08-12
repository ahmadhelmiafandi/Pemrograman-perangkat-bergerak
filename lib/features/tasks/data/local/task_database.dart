import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Skema database SQLite untuk tabel tasks.
class TaskSchema {
  const TaskSchema._();

  static const String table = 'tasks';
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnDescription = 'description';
  static const String columnDueDate = 'due_date';
  static const String columnPriority = 'priority';
  static const String columnIsCompleted = 'is_completed';

  static const String createTable = '''
CREATE TABLE $table (
  $columnId TEXT PRIMARY KEY,
  $columnTitle TEXT NOT NULL,
  $columnDescription TEXT NOT NULL DEFAULT '',
  $columnDueDate TEXT NOT NULL,
  $columnPriority TEXT NOT NULL,
  $columnIsCompleted INTEGER NOT NULL DEFAULT 0
)
''';
}

/// Pengelola koneksi database SQLite untuk Task Tracker.
class TaskDatabase {
  TaskDatabase({this.fileName = 'tasks.db'});

  final String fileName;
  Database? _db;

  /// Membuka atau mengambil instance koneksi database (lazy open).
  Future<Database> database() async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final String path;
    if (fileName == inMemoryDatabasePath) {
      path = inMemoryDatabasePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, fileName);
    }
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(TaskSchema.createTable);
      },
    );
  }
}
