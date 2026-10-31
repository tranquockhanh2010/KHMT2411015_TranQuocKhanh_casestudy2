import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:casestudy2/main.dart';
import 'package:casestudy2/models/task.dart';
import 'package:casestudy2/services/task_api_service.dart';

class _FakeTaskApiService extends TaskApiService {
  _FakeTaskApiService(this.tasks);

  final List<Task> tasks;

  @override
  Future<List<Task>> getTasks() async => tasks;
}

void main() {
  testWidgets('renders tasks returned by the API service', (tester) async {
    final service = _FakeTaskApiService([
      const Task(
        id: '1',
        title: 'Học Flutter',
        description: 'Tìm hiểu REST API',
        category: 'Study',
        priority: 'High',
        status: 'Pending',
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: TaskListScreen(apiService: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Công việc của tôi'), findsOneWidget);
    expect(find.text('Học Flutter'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
  });
}
