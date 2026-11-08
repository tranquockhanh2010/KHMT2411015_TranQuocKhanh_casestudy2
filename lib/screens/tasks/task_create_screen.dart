import 'package:flutter/material.dart';

import '../../services/task_service.dart';
import 'task_edit_screen.dart';

class TaskCreateScreen extends StatelessWidget {
  const TaskCreateScreen({super.key, required this.taskService});

  final TaskService taskService;

  @override
  Widget build(BuildContext context) {
    return TaskEditScreen(taskService: taskService);
  }
}
