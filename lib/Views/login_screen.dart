import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app2/Provider/auth_provider.dart';
import 'package:recipe_app2/Utils/constants.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      backgroundColor: kbackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Icon / Illustration Badge
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: kprimaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Iconsax.book_1,
                        size: 56,
                        color: kprimaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Title & Subtitle
                const Text(
                  "Cook The Best\nRecipes At Home",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Sign in to access delicious recipes, scale ingredients for any serving size, and save your favorites.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Error message banner if any
                if (authProvider.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authProvider.errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Google Sign In Button
                ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          await authProvider.signInWithGoogle();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 1,
                    shadowColor: Colors.black.withValues(alpha: 0.08),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Image.network(
                                "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png",
                                height: 22,
                                width: 22,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.g_mobiledata,
                                  size: 24,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Continue with Google",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 16),

                // Guest Mode Button
                OutlinedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          await authProvider.signInAsGuest();
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kprimaryColor,
                    side: const BorderSide(color: kprimaryColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.user, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Explore as Guest",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Terms footer
                Text(
                  "By continuing, you agree to our Terms of Service\nand Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
