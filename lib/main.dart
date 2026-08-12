import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'features/tasks/data/local/local_task_datasource.dart';
import 'features/tasks/data/local/task_database.dart';
import 'features/tasks/data/remote/api_config.dart';
import 'features/tasks/data/remote/http_task_api_client.dart';
import 'features/tasks/data/remote/mock_task_api_client.dart';
import 'features/tasks/data/remote/remote_task_datasource.dart';
import 'features/tasks/data/remote/task_api_client.dart';
import 'features/tasks/data/repositories/offline_first_task_repository.dart';
import 'features/tasks/presentation/providers/task_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi SQLite lokal (Local Source of Truth - Jalur B)
  final localDatabase = TaskDatabase();
  final localDatasource = LocalTaskDatasource(localDatabase);

  // 2. Inisialisasi Remote Client (Mock API / HTTP REST API)
  final TaskApiClient apiClient = ApiConfig.useMock
      ? MockTaskApiClient()
      : HttpTaskApiClient();
  final remoteDatasource = RemoteTaskDatasource(apiClient);

  // 3. Merangkai Repository Koordinator Offline-First
  final repository = OfflineFirstTaskRepository(
    local: localDatasource,
    remote: remoteDatasource,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(repository: repository)..loadTasks(),
      child: const TaskTrackerApp(),
    ),
  );
}
