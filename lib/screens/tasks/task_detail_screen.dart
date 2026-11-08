import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/notification_service.dart';
import '../../services/task_service.dart';
import '../../services/task_share_service.dart';
import '../../services/user_service.dart';
import '../../services/statistics_service.dart';
import 'task_create_screen.dart';
import '../notifications/notification_screen.dart';
import '../profile/profile_screen.dart';
import 'task_list_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.user,
    required this.taskService,
    required this.notificationService,
    required this.taskShareService,
    required this.userService,
    required this.statisticsService,
    required this.onLogout,
  });

  final User user;
  final TaskService taskService;
  final NotificationService notificationService;
  final TaskShareService taskShareService;
  final UserService userService;
  final StatisticsService statisticsService;
  final VoidCallback onLogout;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      TaskListScreen(
        taskService: widget.taskService,
        shareService: widget.taskShareService,
        userService: widget.userService,
      ),
      NotificationScreen(service: widget.notificationService),
      ProfileScreen(
        user: widget.user,
        userService: widget.userService,
        statisticsService: widget.statisticsService,
        onLogout: widget.onLogout,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(['Công việc', 'Thông báo', 'Cá nhân'][_tab]),
      ),
      body: pages[_tab],
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              onPressed: () async {
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => TaskCreateScreen(taskService: widget.taskService),
                  ),
                );
                if (changed == true && mounted) setState(() {});
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.task), label: 'Công việc'),
          NavigationDestination(
            icon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}
