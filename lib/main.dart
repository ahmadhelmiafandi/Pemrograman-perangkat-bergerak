import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'features/tasks/presentation/providers/task_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider()..loadTasks(),
      child: const TaskTrackerApp(),
    ),
  );
}
