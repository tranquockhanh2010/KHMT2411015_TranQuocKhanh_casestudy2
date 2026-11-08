import 'package:flutter/material.dart';

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(priority));
  }
}
