import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app2/Provider/auth_provider.dart';
import 'package:recipe_app2/Views/app_main_screen.dart';
import 'package:recipe_app2/Views/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);

    if (authProvider.isAuthenticated) {
      return const AppMainScreen();
    } else {
      return const LoginScreen();
    }
  }
}
