import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app2/Provider/auth_provider.dart';
import 'package:recipe_app2/Utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Settings & Profile",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: kprimaryColor.withValues(alpha: 0.15),
                    backgroundImage: (user?.photoURL != null)
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: (user?.photoURL == null)
                        ? const Icon(
                            Iconsax.user,
                            size: 36,
                            color: kprimaryColor,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? "Guest Chef",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? "Signed in as Guest",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: (user?.isGuest ?? true)
                                ? Colors.amber.shade100
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            (user?.isGuest ?? true) ? "Guest Account" : "Google Account",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: (user?.isGuest ?? true)
                                  ? Colors.amber.shade900
                                  : Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Preferences Section
            _buildSection(
              title: "Preferences",
              items: [
                _buildTile(
                  icon: Iconsax.notification,
                  title: "Cooking Notifications",
                  subtitle: "Daily recipes & meal alerts",
                  trailing: Switch(
                    value: true,
                    activeThumbImage: null,
                    activeThumbColor: kprimaryColor,
                    onChanged: (val) {},
                  ),
                ),
                _buildTile(
                  icon: Iconsax.weight_1,
                  title: "Measurement Units",
                  subtitle: "Metric (Grams / Liters)",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // App Info Section
            _buildSection(
              title: "About",
              items: [
                _buildTile(
                  icon: Iconsax.info_circle,
                  title: "About Recipe App",
                  subtitle: "Version 1.0.0 (Flutter & Firebase)",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ),
                _buildTile(
                  icon: Iconsax.shield_tick,
                  title: "Privacy Policy",
                  subtitle: "Your data is secure",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.red.shade200, width: 1.2),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Text("Sign Out"),
                      content: const Text("Are you sure you want to sign out?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await authProvider.signOut();
                          },
                          child: Text(
                            "Sign Out",
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.logout, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Sign Out",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kbackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: kprimaryColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      trailing: trailing,
    );
  }
}
