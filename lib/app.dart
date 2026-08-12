import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/tasks/presentation/screens/task_list_screen.dart';

class TaskTrackerApp extends StatelessWidget {
  const TaskTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const TaskListScreen(),
    );
  }
}
