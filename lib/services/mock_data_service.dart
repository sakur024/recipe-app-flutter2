import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe_app2/models/recipe_model.dart';

class MockDataService {
  static final List<Map<String, dynamic>> defaultCategories = [
    {"name": "All"},
    {"name": "Breakfast"},
    {"name": "Lunch"},
    {"name": "Dinner"},
    {"name": "Salads"},
    {"name": "Dessert"},
  ];

  static final List<Map<String, dynamic>> defaultRecipes = [
    {
      "name": "Grilled Chicken Salad",
      "image": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=70",
      "cal": "250",
      "time": "20",
      "rate": "4.8",
      "reviews": "42",
      "category": "Breakfast",
      "ingredientsAmount": [200.0, 100.0, 50.0, 30.0],
      "ingredientsName": ["Chicken Breast", "Lettuce", "Tomatoes", "Olive Oil"],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1604503468506-a8da13d82791?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1556801712-76c8eb07bbc9?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Crispy Mushroom Salad",
      "image": "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=400&q=70",
      "cal": "180",
      "time": "15",
      "rate": "4.6",
      "reviews": "28",
      "category": "Salads",
      "ingredientsAmount": [150.0, 80.0, 40.0, 20.0],
      "ingredientsName": ["Fresh Mushrooms", "Baby Spinach", "Parmesan", "Garlic"],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1452195100486-9cc805987862?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Shrimp Kale Power Bowl",
      "image": "https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=400&q=70",
      "cal": "320",
      "time": "25",
      "rate": "4.9",
      "reviews": "54",
      "category": "Dinner",
      "ingredientsAmount": [180.0, 120.0, 60.0, 15.0],
      "ingredientsName": ["Shrimp", "Kale Greens", "Avocado", "Lime Dressing"],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1524179091875-bf99a9a6fa57?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Oatmeal Banana Porridge",
      "image": "https://images.unsplash.com/photo-1517673132405-a56a62b18caf?auto=format&fit=crop&w=400&q=70",
      "cal": "290",
      "time": "10",
      "rate": "4.7",
      "reviews": "39",
      "category": "Breakfast",
      "ingredientsAmount": [100.0, 150.0, 50.0, 20.0],
      "ingredientsName": ["Rolled Oats", "Almond Milk", "Ripe Banana", "Honey"],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1586444248902-2f64eddc13df?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Thai Green Noodle Salad",
      "image": "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=400&q=70",
      "cal": "340",
      "time": "18",
      "rate": "4.5",
      "reviews": "22",
      "category": "Lunch",
      "ingredientsAmount": [160.0, 70.0, 50.0, 30.0],
      "ingredientsName": ["Rice Noodles", "Cucumber", "Cilantro", "Peanut Sauce"],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1612927601601-6638404737ce?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1449339854873-750e6913301b?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=120&q=60",
      ],
    },
    {
      "name": "Berry Chia Pudding",
      "image": "https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=400&q=70",
      "cal": "210",
      "time": "12",
      "rate": "4.9",
      "reviews": "67",
      "category": "Dessert",
      "ingredientsAmount": [60.0, 180.0, 70.0, 15.0],
      "ingredientsName": ["Chia Seeds", "Coconut Milk", "Fresh Berries", "Maple Syrup"],
      "ingredientsImage": [
        "https://images.unsplash.com/photo-1509358271058-acd22cc93898?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1464965911861-746a04b4bca6?auto=format&fit=crop&w=120&q=60",
        "https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=120&q=60",
      ],
    },
  ];

  static final List<RecipeModel> customRecipes = [];
  static const String _storageKey = "saved_custom_recipes_v1";

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_storageKey);
      if (savedJson != null && savedJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(savedJson);
        customRecipes.clear();
        for (var item in list) {
          if (item is Map<String, dynamic>) {
            customRecipes.add(RecipeModel.fromJson(item));
          }
        }
      }
    } catch (e) {
      debugPrint("Custom recipes init error: $e");
    }
  }

  static Future<void> _persistCustomRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = customRecipes.map((r) => r.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(list));
    } catch (e) {
      debugPrint("Custom recipes persist error: $e");
    }
  }

  static List<RecipeModel> get allRecipes {
    return [...customRecipes, ...mockRecipes];
  }

  static List<RecipeModel> get mockRecipes {
    return defaultRecipes.asMap().entries.map((entry) {
      return RecipeModel.fromMap(entry.value, "mock_${entry.key}");
    }).toList();
  }

  /// Saves a recipe to both local storage (immediate guarantee)
  /// and Firestore (cloud sync with timeout).
  static Future<bool> saveRecipe(RecipeModel recipe, {DocumentSnapshot? docSnap}) async {
    // 1. Update in-memory and local storage immediately
    final existingIndex = customRecipes.indexWhere(
      (r) => r.id == recipe.id || r.name.trim().toLowerCase() == recipe.name.trim().toLowerCase(),
    );
    if (existingIndex >= 0) {
      customRecipes[existingIndex] = recipe;
    } else {
      customRecipes.insert(0, recipe);
    }
    await _persistCustomRecipes();

    // 2. Sync to Firestore in the cloud
    bool cloudSuccess = false;
    try {
      final collection = FirebaseFirestore.instance.collection("Complete-Flutter-App");
      if (docSnap != null) {
        await docSnap.reference
            .update(recipe.toMap())
            .timeout(const Duration(seconds: 4));
        cloudSuccess = true;
      } else if (recipe.id.isNotEmpty &&
          !recipe.id.startsWith("custom_") &&
          !recipe.id.startsWith("mock_")) {
        await collection
            .doc(recipe.id)
            .set(recipe.toMap(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 4));
        cloudSuccess = true;
      } else {
        final docRef = await collection
            .add(recipe.toMap())
            .timeout(const Duration(seconds: 4));
        cloudSuccess = true;
        final updatedRecipe = RecipeModel(
          id: docRef.id,
          name: recipe.name,
          image: recipe.image,
          cal: recipe.cal,
          time: recipe.time,
          rate: recipe.rate,
          reviews: recipe.reviews,
          category: recipe.category,
          ingredientsAmount: recipe.ingredientsAmount,
          ingredientsName: recipe.ingredientsName,
          ingredientsImage: recipe.ingredientsImage,
        );
        final idx = customRecipes.indexWhere((r) => r.id == recipe.id);
        if (idx >= 0) {
          customRecipes[idx] = updatedRecipe;
          await _persistCustomRecipes();
        }
      }
    } catch (e) {
      debugPrint("Cloud sync note (saved locally): $e");
    }

    return cloudSuccess;
  }

  /// Deletes a recipe from local storage and Firestore.
  static Future<bool> deleteRecipe(String id, {DocumentSnapshot? docSnap}) async {
    customRecipes.removeWhere((r) => r.id == id);
    await _persistCustomRecipes();

    bool cloudSuccess = false;
    try {
      if (docSnap != null) {
        await docSnap.reference.delete().timeout(const Duration(seconds: 4));
        cloudSuccess = true;
      } else if (id.isNotEmpty && !id.startsWith("custom_") && !id.startsWith("mock_")) {
        await FirebaseFirestore.instance
            .collection("Complete-Flutter-App")
            .doc(id)
            .delete()
            .timeout(const Duration(seconds: 4));
        cloudSuccess = true;
      }
    } catch (e) {
      debugPrint("Cloud delete note (deleted locally): $e");
    }
    return cloudSuccess;
  }

  // Auto-seeds Firestore with initial categories and recipes if empty
  static Future<void> seedFirestoreIfEmpty() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Fetch existing categories
      final catSnap = await firestore
          .collection("App-Category")
          .get()
          .timeout(const Duration(seconds: 4));

      final existingCatNames = catSnap.docs
          .map((doc) => doc.data()['name']?.toString() ?? "")
          .toSet();

      for (var cat in defaultCategories) {
        if (!existingCatNames.contains(cat['name'])) {
          try {
            await firestore
                .collection("App-Category")
                .add(cat)
                .timeout(const Duration(seconds: 3));
          } catch (e) {
            debugPrint("Category add error: $e");
          }
        }
      }

      // Fetch existing recipes
      final recipeSnap = await firestore
          .collection("Complete-Flutter-App")
          .get()
          .timeout(const Duration(seconds: 5));

      final existingRecipeNames = recipeSnap.docs
          .map((doc) => doc.data()['name']?.toString().toLowerCase() ?? "")
          .toSet();

      for (var recipe in defaultRecipes) {
        final recipeName = (recipe['name']?.toString() ?? "").toLowerCase();
        if (!existingRecipeNames.contains(recipeName)) {
          try {
            await firestore
                .collection("Complete-Flutter-App")
                .add(recipe)
                .timeout(const Duration(seconds: 3));
            debugPrint("Seeded missing recipe: ${recipe['name']}");
          } catch (e) {
            debugPrint("Recipe add error: $e");
          }
        }
      }
    } catch (e) {
      debugPrint("Note: Auto-seeding skipped or partial: $e");
    }
  }
}
