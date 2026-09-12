import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app2/Provider/auth_provider.dart';
import 'package:recipe_app2/Provider/favorite_provider.dart';
import 'package:recipe_app2/Provider/meal_plan_provider.dart';
import 'package:recipe_app2/Utils/constants.dart';
import 'package:recipe_app2/Views/app_main_screen.dart';
import 'package:recipe_app2/Views/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final user = authProvider.currentUser;

    // Immediately propagate the active account UID to all data providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<FavoriteProvider>().checkUserChanged(user?.uid);
        context.read<MealPlanProvider>().checkUserChanged(user?.uid);
      }
    });

    // Wait for session restoration from local disk
    if (authProvider.isInitializing) {
      return const Scaffold(
        backgroundColor: kbackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: kprimaryColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "FlavorCraft",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      return AppMainScreen(key: ValueKey(user?.uid ?? 'guest'));
    } else {
      return const LoginScreen();
    }
  }
}
