import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:recipe_app2/Utils/constants.dart';
import 'package:recipe_app2/Views/view_all_items.dart';
import 'package:recipe_app2/Widget/banner.dart';
import 'package:recipe_app2/Widget/food_items_display.dart';
import 'package:recipe_app2/Widget/my_icon_button.dart';
import 'package:recipe_app2/models/recipe_model.dart';
import 'package:recipe_app2/services/mock_data_service.dart';

class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({super.key});

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  String category = "All";
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  bool get _isFirebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  CollectionReference? get categoriesItems {
    if (_isFirebaseReady) {
      try {
        return FirebaseFirestore.instance.collection("App-Category");
      } catch (_) {}
    }
    return null;
  }

  Query? get filteredRecipes {
    if (_isFirebaseReady) {
      try {
        return FirebaseFirestore.instance
            .collection("Complete-Flutter-App")
            .where('category', isEqualTo: category);
      } catch (_) {}
    }
    return null;
  }

  Query? get allRecipes {
    if (_isFirebaseReady) {
      try {
        return FirebaseFirestore.instance.collection("Complete-Flutter-App");
      } catch (_) {}
    }
    return null;
  }

  Query? get selectedRecipes =>
      category == "All" ? allRecipes : filteredRecipes;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerParts(),
                    mySearchBar(),
                    const BannerToExplore(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    selectedCategory(),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Quick & Easy",
                          style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 0.1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ViewAllItems(),
                              ),
                            );
                          },
                          child: const Text(
                            "View all",
                            style: TextStyle(
                              color: kBannerColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildRecipesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipesSection() {
    final query = selectedRecipes;

    if (query != null) {
      return StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            // Extract recipes from Firestore
            final List<dynamic> combinedList = [];
            final Set<String> loadedNames = {};

            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              final name = (data['name']?.toString() ?? "").toLowerCase();
              if (name.isNotEmpty) {
                loadedNames.add(name);
                combinedList.add(doc);
              }
            }

            // Supplement with default recipes if not already present
            for (var mock in MockDataService.mockRecipes) {
              if (!loadedNames.contains(mock.name.toLowerCase())) {
                if (category == "All" || mock.category.toLowerCase() == category.toLowerCase()) {
                  combinedList.add(mock);
                  loadedNames.add(mock.name.toLowerCase());
                }
              }
            }

            // Apply search filter if active
            List<dynamic> filtered = combinedList;
            if (searchQuery.isNotEmpty) {
              filtered = filtered.where((item) {
                String name = "";
                if (item is DocumentSnapshot) {
                  final data = item.data() as Map<String, dynamic>? ?? {};
                  name = data['name']?.toString().toLowerCase() ?? "";
                } else if (item is RecipeModel) {
                  name = item.name.toLowerCase();
                }
                return name.contains(searchQuery.toLowerCase());
              }).toList();
            }

            if (filtered.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    "No recipes found for this category",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(top: 5, left: 15, bottom: 25),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filtered.map((item) {
                    if (item is DocumentSnapshot) {
                      return FoodItemsDisplay(documentSnapshot: item);
                    } else {
                      return FoodItemsDisplay(recipe: item as RecipeModel);
                    }
                  }).toList(),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Fallback to mock recipes if Firestore is empty
          return _buildMockRecipesRow();
        },
      );
    }

    // Fallback when Firebase is not connected
    return _buildMockRecipesRow();
  }

  Widget _buildMockRecipesRow() {
    List<RecipeModel> items = MockDataService.mockRecipes;

    if (category != "All") {
      items = items.where((r) => r.category == category).toList();
    }

    if (searchQuery.isNotEmpty) {
      items = items
          .where((r) => r.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            "No recipes found for this category",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 15, bottom: 25),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items
              .map((r) => FoodItemsDisplay(recipe: r))
              .toList(),
        ),
      ),
    );
  }

  Widget selectedCategory() {
    final catCol = categoriesItems;

    if (catCol != null) {
      return StreamBuilder<QuerySnapshot>(
        stream: catCol.snapshots(),
        builder: (context, snapshot) {
          List<String> catNames = [];
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            catNames = snapshot.data!.docs
                .map((doc) => doc['name'].toString())
                .toList();
          } else {
            catNames = MockDataService.defaultCategories
                .map((c) => c['name'].toString())
                .toList();
          }
          return _buildCategoryChips(catNames);
        },
      );
    }

    final catNames = MockDataService.defaultCategories
        .map((c) => c['name'].toString())
        .toList();
    return _buildCategoryChips(catNames);
  }

  Widget _buildCategoryChips(List<String> catNames) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          catNames.length,
          (index) {
            final catName = catNames[index];
            final isSelected = category == catName;
            return GestureDetector(
              onTap: () {
                setState(() {
                  category = catName;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: isSelected ? kprimaryColor : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                margin: const EdgeInsets.only(right: 15),
                child: Text(
                  catName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget mySearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            searchQuery = val;
          });
        },
        decoration: InputDecoration(
          filled: true,
          prefixIcon: const Icon(Iconsax.search_normal, color: Colors.grey),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchQuery = "";
                    });
                  },
                )
              : null,
          fillColor: Colors.white,
          border: InputBorder.none,
          hintText: "Search any recipes",
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: kprimaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget headerParts() {
    return Row(
      children: [
        const Text(
          "What are you\ncooking today?",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.1,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        MyIconButton(
          icon: Iconsax.notification,
          pressed: () {},
        ),
      ],
    );
  }
}
