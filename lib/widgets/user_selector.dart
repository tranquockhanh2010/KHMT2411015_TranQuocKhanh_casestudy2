import 'package:flutter/material.dart';

class UserSelector extends StatelessWidget {
  const UserSelector({super.key, this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(labelText: 'Email người dùng'),
      onChanged: onChanged,
    );
  }
}
