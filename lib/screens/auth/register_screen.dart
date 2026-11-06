import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({
    super.key,
    required this.authService,
    required this.onAuthenticated,
  });

  final AuthService authService;
  final ValueChanged<User> onAuthenticated;

  @override
  Widget build(BuildContext context) => LoginScreen(
      authService: authService,
      onAuthenticated: onAuthenticated,
      initialRegistering: true,
    );
}
