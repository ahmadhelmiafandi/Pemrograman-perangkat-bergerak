import 'package:flutter_test/flutter_test.dart';
import 'package:p03_provider_crud/core/errors/api_error.dart';
import 'package:p03_provider_crud/features/tasks/data/remote/mock_task_api_client.dart';
import 'package:p03_provider_crud/features/tasks/domain/task.dart';

void main() {
  late MockTaskApiClient client;

  setUp(() {
    client = MockTaskApiClient();
  });

  group('MockTaskApiClient Unit Tests', () {
    test('listTasks mengembalikan fixture default offline', () async {
      final tasks = await client.listTasks();
      expect(tasks, isNotEmpty);
      expect(tasks.length, 3);
    });

    test('createTask menambah task ke mock list', () async {
      final newTask = Task(
        id: 'new-01',
        title: 'New Mock Task',
        description: 'Mock test',
        dueDate: DateTime.now(),
      );

      await client.createTask(newTask);
      final tasks = await client.listTasks();
      expect(tasks.length, 4);
      expect(tasks.any((t) => t.id == 'new-01'), isTrue);
    });

    test('createTask melempar ClientError 409 jika ID sudah ada', () async {
      final duplicateTask = Task(
        id: 'mock-01',
        title: 'Duplicate Task',
        description: 'Should fail',
        dueDate: DateTime.now(),
      );

      expect(
        () => client.createTask(duplicateTask),
        throwsA(isA<ClientError>()),
      );
    });

    test('updateTask memperbarui data task yang ada', () async {
      final updatedTask = Task(
        id: 'mock-01',
        title: 'Updated Fixture Title',
        description: 'Updated description',
        dueDate: DateTime.now(),
        isCompleted: true,
      );

      await client.updateTask(updatedTask);
      final tasks = await client.listTasks();
      final target = tasks.firstWhere((t) => t.id == 'mock-01');
      expect(target.title, 'Updated Fixture Title');
      expect(target.isCompleted, isTrue);
    });

    test('updateTask melempar NotFoundError jika ID tidak ada', () async {
      final missingTask = Task(
        id: 'missing-99',
        title: 'Missing Task',
        description: 'No id',
        dueDate: DateTime.now(),
      );

      expect(
        () => client.updateTask(missingTask),
        throwsA(isA<NotFoundError>()),
      );
    });

    test('deleteTask menghapus task dari mock list', () async {
      await client.deleteTask('mock-01');
      final tasks = await client.listTasks();
      expect(tasks.length, 2);
      expect(tasks.any((t) => t.id == 'mock-01'), isFalse);
    });

    test('simulateNetworkError melempar NetworkError saat diaktifkan', () async {
      client.simulateNetworkError = true;
      expect(
        () => client.listTasks(),
        throwsA(isA<NetworkError>()),
      );
    });
  });
}
