import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app2/Provider/auth_provider.dart';
import 'package:recipe_app2/Provider/favorite_provider.dart';
import 'package:recipe_app2/Utils/constants.dart';
import 'package:recipe_app2/Views/add_edit_recipe_screen.dart';
import 'package:recipe_app2/Views/notifications_screen.dart';
import 'package:recipe_app2/Views/recipe_detail_screen.dart';
import 'package:recipe_app2/Widget/my_icon_button.dart';
import 'package:recipe_app2/models/recipe_model.dart';
import 'package:recipe_app2/services/mock_data_service.dart';

class ViewAllItems extends StatefulWidget {
  const ViewAllItems({super.key});

  @override
  State<ViewAllItems> createState() => _ViewAllItemsState();
}

class _ViewAllItemsState extends State<ViewAllItems> {
  bool get _isFirebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  CollectionReference? get completeApp {
    if (_isFirebaseReady) {
      try {
        return FirebaseFirestore.instance.collection("Complete-Flutter-App");
      } catch (_) {}
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      backgroundColor: kbackgroundColor,
      floatingActionButton: authProvider.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: kprimaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add),
              label: const Text(
                "Add Recipe",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditRecipeScreen(),
                  ),
                );
                if (result == true && mounted) {
                  setState(() {});
                }
              },
            )
          : null,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          const SizedBox(width: 15),
          MyIconButton(
            icon: Icons.arrow_back_ios_new,
            pressed: () {
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Text(
            "Quick & Easy",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          MyIconButton(
            icon: Iconsax.notification,
            hasBadge: true,
            pressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: _buildGridContent(),
      ),
    );
  }

  Widget _buildGridContent() {
    final col = completeApp;
    if (col != null) {
      return StreamBuilder<QuerySnapshot>(
        stream: col.snapshots(),
        builder: (context, streamSnapshot) {
          if (streamSnapshot.hasData) {
            // Combine custom recipes, Firestore docs, and mock recipes
            final List<dynamic> allItems = [];
            final Set<String> itemNames = {};

            // 1. Add locally published/edited recipes first
            for (var custom in MockDataService.customRecipes) {
              if (!itemNames.contains(custom.name.toLowerCase())) {
                allItems.add(custom);
                itemNames.add(custom.name.toLowerCase());
              }
            }

            // 2. Add Firestore documents
            for (var doc in streamSnapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              final name = (data['name']?.toString() ?? "").toLowerCase();
              if (name.isNotEmpty && !itemNames.contains(name)) {
                itemNames.add(name);
                allItems.add(doc);
              }
            }

            // 3. Supplement with default recipes if not already present
            for (var mock in MockDataService.mockRecipes) {
              if (!itemNames.contains(mock.name.toLowerCase())) {
                allItems.add(mock);
                itemNames.add(mock.name.toLowerCase());
              }
            }

            if (allItems.isNotEmpty) {
              return _renderGrid(allItems);
            }
          }

          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 100),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return _renderGrid(MockDataService.allRecipes);
        },
      );
    }

    return _renderGrid(MockDataService.allRecipes);
  }

  Widget _renderGrid(List<dynamic> items) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58, // Ample height so text and ratings never collide
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        DocumentSnapshot? doc;
        RecipeModel? model;
        Map<String, dynamic> data = {};

        if (item is DocumentSnapshot) {
          doc = item;
          data = item.data() as Map<String, dynamic>? ?? {};
        } else if (item is RecipeModel) {
          model = item;
          data = item.toMap();
        }

        final String itemId = model?.id ?? doc?.id ?? "recipe_$index";
        final String name = model?.name ?? (data['name']?.toString() ?? "Recipe");
        final String image = model?.image ?? (data['image']?.toString() ?? "");
        final String cal = model?.cal ?? (data['cal']?.toString() ?? "0");
        final String time = model?.time ?? (data['time']?.toString() ?? "0");
        final String rate = model?.rate ?? (data['rate']?.toString() ?? "4.8");
        final String reviews = model?.reviews ?? (data['reviews']?.toString() ?? "20");

        final favoriteProvider = FavoriteProvider.of(context);
        final bool isFav = favoriteProvider.isExist(doc ?? itemId);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeDetailScreen(
                  documentSnapshot: doc,
                  recipe: model,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Header with Heart Icon
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      child: Container(
                        height: 135,
                        width: double.infinity,
                        color: Colors.grey.shade100,
                        child: image.isNotEmpty
                            ? Image.network(
                                image,
                                fit: BoxFit.cover,
                                frameBuilder: (context, child, frame, wasSync) {
                                  if (wasSync || frame != null) return child;
                                  return Container(color: Colors.grey.shade100);
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Icon(Icons.fastfood, color: Colors.grey, size: 36),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.fastfood, color: Colors.grey, size: 36),
                              ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        child: InkWell(
                          onTap: () {
                            favoriteProvider.toggleFavorite(doc ?? itemId);
                          },
                          child: Icon(
                            isFav ? Iconsax.heart5 : Iconsax.heart,
                            color: isFav ? Colors.red : Colors.black87,
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Card Details with plenty of breathing space
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe Title (Clear, High Contrast, 2 Lines max)
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Rating & Reviews row
                      Row(
                        children: [
                          const Icon(
                            Iconsax.star1,
                            color: Colors.amber,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rate,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            " ($reviews)",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Calories & Time row (Distinct and completely separated)
                      Row(
                        children: [
                          Icon(
                            Iconsax.flash_1,
                            size: 14,
                            color: kprimaryColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "$cal Cal",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: kprimaryColor,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Iconsax.clock,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "$time Min",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
