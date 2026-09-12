import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app2/Provider/auth_provider.dart';
import 'package:recipe_app2/Utils/constants.dart';
import 'package:recipe_app2/Views/favorite_screen.dart';
import 'package:recipe_app2/Views/notifications_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Interactive user preferences state
  bool _cookingNotifications = true;
  bool _mealReminders = true;
  String _selectedUnit = "Metric (Grams, ml, °C)";
  String _selectedDiet = "No Restrictions";

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _cookingNotifications = prefs.getBool('pref_cooking_notifs') ?? true;
        _mealReminders = prefs.getBool('pref_meal_reminders') ?? true;
        _selectedUnit = prefs.getString('pref_unit') ?? "Metric (Grams, ml, °C)";
        _selectedDiet = prefs.getString('pref_diet') ?? "No Restrictions";
      });
    } catch (_) {}
  }

  Future<void> _savePreference(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    } catch (_) {}
  }

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
            // Profile Card (Clickable to view/edit details)
            InkWell(
              onTap: () => _showEditProfileDialog(context, authProvider),
              borderRadius: BorderRadius.circular(20),
              child: Container(
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
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: kprimaryColor.withValues(alpha: 0.15),
                          backgroundImage: (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: (user?.photoURL == null || user!.photoURL!.isEmpty)
                              ? const Icon(
                                  Iconsax.user,
                                  size: 36,
                                  color: kprimaryColor,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: kprimaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  (user?.displayName != null &&
                                          user!.displayName!.isNotEmpty)
                                      ? user.displayName!
                                      : ((user?.isGuest ?? true)
                                          ? "Guest Chef"
                                          : "Chef Gourmet"),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ??
                                ((user?.isGuest ?? true)
                                    ? "Signed in as Guest"
                                    : "Verified User"),
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
                              (user?.isGuest ?? true)
                                  ? "Guest Account • Tap to edit"
                                  : ((user?.photoURL != null &&
                                          user!.photoURL!.contains("google"))
                                      ? "Google Account • Verified"
                                      : "Verified Account"),
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
            ),
            const SizedBox(height: 25),

            // Cooking & Quick Shortcuts Section
            _buildSection(
              title: "My Cooking Activity",
              items: [
                _buildTile(
                  icon: Iconsax.heart,
                  title: "Favorite Recipes",
                  subtitle: "View all bookmarked dishes",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoriteScreen(),
                      ),
                    );
                  },
                ),
                _buildTile(
                  icon: Iconsax.filter,
                  title: "Dietary Preference",
                  subtitle: _selectedDiet,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showDietaryDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Preferences Section
            _buildSection(
              title: "Preferences",
              items: [
                _buildTile(
                  icon: Iconsax.notification_bing,
                  title: "Notifications Center",
                  subtitle: "View alerts, reminders & tips",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                _buildTile(
                  icon: Iconsax.notification,
                  title: "Cooking Notifications",
                  subtitle: "Daily recipe recommendations",
                  trailing: Switch(
                    value: _cookingNotifications,
                    activeThumbColor: kprimaryColor,
                    onChanged: (val) {
                      setState(() {
                        _cookingNotifications = val;
                      });
                      _savePreference('pref_cooking_notifs', val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            val
                                ? "Cooking notifications turned ON"
                                : "Cooking notifications turned OFF",
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
                _buildTile(
                  icon: Iconsax.clock,
                  title: "Meal Reminders",
                  subtitle: "Alerts for breakfast, lunch & dinner",
                  trailing: Switch(
                    value: _mealReminders,
                    activeThumbColor: kprimaryColor,
                    onChanged: (val) {
                      setState(() {
                        _mealReminders = val;
                      });
                      _savePreference('pref_meal_reminders', val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            val
                                ? "Meal reminders enabled"
                                : "Meal reminders disabled",
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
                _buildTile(
                  icon: Iconsax.weight_1,
                  title: "Measurement Units",
                  subtitle: _selectedUnit,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showUnitsDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // App Info Section
            _buildSection(
              title: "Support & About",
              items: [
                _buildTile(
                  icon: Iconsax.info_circle,
                  title: "About Recipe App",
                  subtitle: "Version 1.0.0 • WTF Code & Flutter",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showAboutDialog(context),
                ),
                _buildTile(
                  icon: Iconsax.shield_tick,
                  title: "Privacy Policy",
                  subtitle: "How we protect your cooking data",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showPrivacyDialog(context),
                ),
                _buildTile(
                  icon: Iconsax.message_question,
                  title: "Help & FAQ",
                  subtitle: "Common questions & support",
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showHelpDialog(context),
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
                      content: const Text(
                        "Are you sure you want to sign out of Recipe App?",
                      ),
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Edit Profile Name Dialog
  void _showEditProfileDialog(BuildContext context, AppAuthProvider authProvider) {
    final user = authProvider.currentUser;
    final controller = TextEditingController(text: user?.displayName ?? "");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Chef Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Update your display name:",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Enter your name",
                filled: true,
                fillColor: kbackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Account: ${user?.email ?? 'Guest Session'}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kprimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await authProvider.updateProfileName(newName);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Profile name updated to: $newName"),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // Units Selection Dialog
  void _showUnitsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Measurement Units"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Metric System"),
              subtitle: const Text("Grams (g), Milliliters (ml), Celsius (°C)"),
              trailing: _selectedUnit.startsWith("Metric")
                  ? const Icon(Icons.check, color: kprimaryColor)
                  : null,
              onTap: () {
                setState(() {
                  _selectedUnit = "Metric (Grams, ml, °C)";
                });
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text("Imperial System"),
              subtitle: const Text("Ounces (oz), Cups, Fahrenheit (°F)"),
              trailing: _selectedUnit.startsWith("Imperial")
                  ? const Icon(Icons.check, color: kprimaryColor)
                  : null,
              onTap: () {
                setState(() {
                  _selectedUnit = "Imperial (oz, cups, °F)";
                });
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Dietary Preferences Dialog
  void _showDietaryDialog(BuildContext context) {
    final diets = [
      "No Restrictions",
      "Vegetarian",
      "Vegan",
      "Keto",
      "Gluten-Free",
      "Halal",
      "Low Carb",
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Dietary Preferences"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: diets.length,
            itemBuilder: (c, idx) {
              final d = diets[idx];
              return ListTile(
                title: Text(d),
                trailing: _selectedDiet == d
                    ? const Icon(Icons.check, color: kprimaryColor)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedDiet = d;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Dietary preference set to $d"),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // About Dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Iconsax.book_1, color: kprimaryColor),
            SizedBox(width: 10),
            Text("About Recipe App"),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Complete Recipe App",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 6),
            Text(
              "Built with Flutter, Firebase Authentication, Cloud Firestore, and Provider state management.\n\n"
              "Features dynamic ingredient scaling, customizable servings, bookmarking, and meal planning.",
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
            ),
            SizedBox(height: 12),
            Text(
              "Version: 1.0.0\nBased on WTF Code Tutorial",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Awesome!"),
          ),
        ],
      ),
    );
  }

  // Privacy Policy Dialog
  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Privacy Policy"),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Data & Privacy",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(height: 8),
              Text(
                "• Your account information (email and name) is used exclusively for authentication.\n"
                "• Your saved recipes and meal schedules are stored securely in Cloud Firestore.\n"
                "• No personal cooking data is sold or shared with third parties.\n"
                "• You can sign out at any time or delete your session by clearing app data.",
                style: TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }

  // Help & FAQ Dialog
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Help & FAQ"),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Q: How do I change ingredient servings?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                "A: Tap on any recipe, then use the (+) or (-) buttons under 'How many servings?'. All gram quantities will scale automatically.",
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              SizedBox(height: 12),
              Text(
                "Q: How do I bookmark a recipe?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                "A: Tap the heart icon on any recipe card or on the detail screen.",
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
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
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
