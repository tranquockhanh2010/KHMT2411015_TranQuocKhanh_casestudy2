import 'package:flutter/material.dart';

import '../../models/task.dart';
import '../../services/task_service.dart';

class TaskEditScreen extends StatefulWidget {
  const TaskEditScreen({
    super.key,
    required this.taskService,
    this.task,
  });

  final TaskService taskService;
  final Task? task;

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  String _priority = 'Medium';
  String _status = 'Pending';
  DateTime? _startDate;
  DateTime? _dueDate;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task?.title);
    _description = TextEditingController(text: widget.task?.description);
    _priority = _normalize(widget.task?.priority, 'Medium');
    _status = _normalize(widget.task?.status, 'Pending');
    _startDate = widget.task?.startDate;
    _dueDate = widget.task?.dueDate;
  }

  String _normalize(String? value, String fallback) {
    const values = {
      'low': 'Low',
      'medium': 'Medium',
      'high': 'High',
      'pending': 'Pending',
      'inprogress': 'InProgress',
      'in_progress': 'InProgress',
      'completed': 'Completed',
      'todo': 'Pending',
    };
    return values[value?.toLowerCase().replaceAll(' ', '_')] ?? fallback;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final body = {
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'priority': _priority,
        'status': _status,
        if (_startDate != null) 'startDate': _startDate!.toIso8601String(),
        if (_dueDate != null) 'dueDate': _dueDate!.toIso8601String(),
      };
      if (widget.task == null) {
        await widget.taskService.create(body);
      } else {
        await widget.taskService.update(widget.task!.id, body);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }

    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickDate({required bool dueDate}) async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: (dueDate ? _dueDate : _startDate) ?? DateTime.now(),
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (dueDate) {
        _dueDate = selected;
      } else {
        _startDate = selected;
      }
    });
  }

  String _dateLabel(DateTime? date) =>
      date == null ? 'Chưa chọn' : '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Thêm công việc' : 'Chỉnh sửa'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Tên công việc'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Nhập tên công việc'
                  : null,
            ),
            TextFormField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Ưu tiên'),
              items: ['Low', 'Medium', 'High']
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _priority = value!),
            ),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Trạng thái'),
              items: ['Pending', 'InProgress', 'Completed']
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _status = value!),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ngày bắt đầu'),
              subtitle: Text(_dateLabel(_startDate)),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _pickDate(dueDate: false),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Hạn hoàn thành'),
              subtitle: Text(_dateLabel(_dueDate)),
              trailing: IconButton(
                icon: const Icon(Icons.event),
                onPressed: () => _pickDate(dueDate: true),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: _busy
                  ? const CircularProgressIndicator()
                  : const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
