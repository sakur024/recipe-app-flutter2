import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:recipe_app2/Utils/constants.dart';
import 'package:recipe_app2/Views/app_main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final String category; // 'reminder', 'tip', 'update'
  bool isRead;

  AppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.category,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'time': time,
        'category': category,
        'isRead': isRead,
      };

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) =>
      AppNotificationItem(
        id: json['id'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        time: json['time'] as String,
        category: json['category'] as String,
        isRead: json['isRead'] as bool? ?? false,
      );
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = "All";
  List<AppNotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  List<AppNotificationItem> _getDefaultNotifications() {
    return [
      AppNotificationItem(
        id: "notif_1",
        title: "Daily Meal Reminder",
        message:
            "Don't forget to check your planned meals for today! Stay on track with your healthy nutrition goals.",
        time: "Just now",
        category: "reminder",
        isRead: false,
      ),
      AppNotificationItem(
        id: "notif_2",
        title: "Chef's Recommendation",
        message:
            "Try our trending 'Creamy Garlic Tuscan Shrimp' recipe tonight. It takes only 25 minutes!",
        time: "2 hours ago",
        category: "tip",
        isRead: false,
      ),
      AppNotificationItem(
        id: "notif_3",
        title: "Kitchen Pro Tip",
        message:
            "Let roasted meats rest 5-10 minutes before slicing to lock in all flavorful juices and tenderness.",
        time: "Yesterday",
        category: "tip",
        isRead: true,
      ),
      AppNotificationItem(
        id: "notif_4",
        title: "Meal Planner Update",
        message:
            "You can now schedule breakfast, lunch, and dinner with dynamic calories and ingredient quantities!",
        time: "2 days ago",
        category: "update",
        isRead: true,
      ),
    ];
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString('saved_notifications');
      if (savedJson != null && savedJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(savedJson);
        setState(() {
          _notifications = decoded
              .map((item) =>
                  AppNotificationItem.fromJson(item as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    setState(() {
      _notifications = _getDefaultNotifications();
      _isLoading = false;
    });
    _saveNotifications();
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(_notifications.map((n) => n.toJson()).toList());
      await prefs.setString('saved_notifications', encoded);
    } catch (_) {}
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
    _saveNotifications();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("All notifications marked as read"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Clear All Notifications?"),
        content: const Text(
          "Are you sure you want to remove all notifications? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _notifications.clear();
              });
              _saveNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("All notifications cleared"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text("Clear All"),
          ),
        ],
      ),
    );
  }

  List<AppNotificationItem> get _filteredNotifications {
    if (_selectedFilter == "Reminders") {
      return _notifications.where((n) => n.category == "reminder").toList();
    } else if (_selectedFilter == "Tips & Recipes") {
      return _notifications.where((n) => n.category == "tip").toList();
    } else if (_selectedFilter == "Updates") {
      return _notifications.where((n) => n.category == "update").toList();
    }
    return _notifications;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "reminder":
        return Iconsax.clock;
      case "tip":
        return Iconsax.lamp_on;
      case "update":
        return Iconsax.magicpen;
      default:
        return Iconsax.notification;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "reminder":
        return Colors.orange;
      case "tip":
        return kprimaryColor;
      case "update":
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: IconButton(
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                backgroundColor: Colors.white,
                fixedSize: const Size(44, 44),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 18,
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Notifications",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: kprimaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$unreadCount",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (val) {
                if (val == "mark_read") {
                  _markAllAsRead();
                } else if (val == "clear_all") {
                  _clearAllNotifications();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "mark_read",
                  child: Row(
                    children: [
                      Icon(Icons.done_all, size: 18, color: kprimaryColor),
                      SizedBox(width: 10),
                      Text("Mark all as read"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "clear_all",
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          size: 18, color: Colors.red.shade700),
                      const SizedBox(width: 10),
                      Text("Clear all",
                          style: TextStyle(color: Colors.red.shade700)),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: kprimaryColor),
            )
          : Column(
              children: [
                // Filter Chips
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip("All"),
                        const SizedBox(width: 8),
                        _buildFilterChip("Reminders"),
                        const SizedBox(width: 8),
                        _buildFilterChip("Tips & Recipes"),
                        const SizedBox(width: 8),
                        _buildFilterChip("Updates"),
                      ],
                    ),
                  ),
                ),

                // Notifications List
                Expanded(
                  child: _filteredNotifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          itemCount: _filteredNotifications.length,
                          separatorBuilder: (ctx, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _filteredNotifications[index];
                            return _buildNotificationCard(item);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kprimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? kprimaryColor.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotificationItem item) {
    final color = _getCategoryColor(item.category);
    final icon = _getCategoryIcon(item.category);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      onDismissed: (_) {
        final removedItem = item;
        final removedIndex = _notifications.indexOf(item);
        setState(() {
          _notifications.remove(item);
        });
        _saveNotifications();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Notification removed"),
            action: SnackBarAction(
              label: "Undo",
              textColor: Colors.amber,
              onPressed: () {
                setState(() {
                  _notifications.insert(removedIndex, removedItem);
                });
                _saveNotifications();
              },
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          setState(() {
            item.isRead = true;
          });
          _saveNotifications();

          if (item.category == "reminder") {
            // Navigate to Meal Plan tab in main screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AppMainScreen()),
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: item.isRead ? Colors.white : const Color(0xFFF6FAF6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.isRead
                  ? Colors.transparent
                  : kprimaryColor.withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),

              // Notification text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: item.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            height: 8,
                            width: 8,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: const BoxDecoration(
                              color: kprimaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.time,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: kprimaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.notification_bing,
                size: 44,
                color: kprimaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "All Caught Up!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You have no notifications right now.\nWe'll alert you with cooking reminders and delicious tips.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
