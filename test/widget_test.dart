import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:p03_provider_crud/app.dart';
import 'package:p03_provider_crud/features/tasks/presentation/providers/task_provider.dart';

void main() {
  testWidgets('app mounts, shows loading lalu list setelah seed', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TaskProvider()..loadTasks(),
        child: const TaskTrackerApp(),
      ),
    );

    // loading state muncul sebentar
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // tunggu Future.delayed 300ms di loadTasks selesai
    await tester.pumpAndSettle();

    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    // minimal satu judul dummy tampil
    expect(find.text('Complete Math Assignment'), findsOneWidget);
  });
}
