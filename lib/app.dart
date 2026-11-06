import 'package:flutter/material.dart';

import 'models/user.dart';
import 'screens/auth/login_screen.dart';
import 'screens/tasks/task_detail_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/task_service.dart';
import 'services/task_share_service.dart';
import 'services/user_service.dart';
import 'services/statistics_service.dart';

class TaskManagerApp extends StatefulWidget {
  const TaskManagerApp({super.key});

  @override
  State<TaskManagerApp> createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {
  final ApiClient _client = ApiClient();
  late final AuthService _auth = AuthService(_client);
  late final TaskService _tasks = TaskService(_client);
  late final NotificationService _notifications = NotificationService(_client);
  late final TaskShareService _shares = TaskShareService(_client);
  late final UserService _users = UserService(_client);
  late final StatisticsService _statistics = StatisticsService(_client);
  User? _user;

  void _authenticated(User user) => setState(() => _user = user);

  void _logout() {
    _auth.logout();
    setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: _user == null
          ? LoginScreen(authService: _auth, onAuthenticated: _authenticated)
          : TaskDetailScreen(
              user: _user!,
              taskService: _tasks,
              notificationService: _notifications,
              taskShareService: _shares,
              userService: _users,
              statisticsService: _statistics,
              onLogout: _logout,
            ),
    );
  }
}
