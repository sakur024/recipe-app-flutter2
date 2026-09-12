import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app2/services/mock_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlannedMeal {
  final String id;
  final String day; // Mon, Tue, Wed, Thu, Fri, Sat, Sun
  final String mealType; // Breakfast, Lunch, Dinner, Snack
  final String recipeName;
  final String time;
  final String calories;
  final String imageUrl;
  final bool isCompleted;

  PlannedMeal({
    required this.id,
    required this.day,
    required this.mealType,
    required this.recipeName,
    required this.time,
    required this.calories,
    required this.imageUrl,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'mealType': mealType,
      'recipeName': recipeName,
      'time': time,
      'calories': calories,
      'imageUrl': imageUrl,
      'isCompleted': isCompleted,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'mealType': mealType,
      'recipeName': recipeName,
      'time': time,
      'calories': calories,
      'imageUrl': imageUrl,
      'isCompleted': isCompleted,
    };
  }

  factory PlannedMeal.fromJson(Map<String, dynamic> data) {
    return PlannedMeal(
      id: data['id'] ?? 'meal_${DateTime.now().millisecondsSinceEpoch}',
      day: data['day'] ?? 'Mon',
      mealType: data['mealType'] ?? 'Breakfast',
      recipeName: data['recipeName'] ?? 'Recipe',
      time: data['time'] ?? '08:00 AM',
      calories: data['calories'] ?? '250 Cal',
      imageUrl: data['imageUrl'] ??
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  factory PlannedMeal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PlannedMeal(
      id: doc.id,
      day: data['day'] ?? 'Mon',
      mealType: data['mealType'] ?? 'Breakfast',
      recipeName: data['recipeName'] ?? 'Recipe',
      time: data['time'] ?? '08:00 AM',
      calories: data['calories'] ?? '250 Cal',
      imageUrl: data['imageUrl'] ??
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  PlannedMeal copyWith({
    String? id,
    String? day,
    String? mealType,
    String? recipeName,
    String? time,
    String? calories,
    String? imageUrl,
    bool? isCompleted,
  }) {
    return PlannedMeal(
      id: id ?? this.id,
      day: day ?? this.day,
      mealType: mealType ?? this.mealType,
      recipeName: recipeName ?? this.recipeName,
      time: time ?? this.time,
      calories: calories ?? this.calories,
      imageUrl: imageUrl ?? this.imageUrl,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class MealPlanProvider extends ChangeNotifier {
  List<PlannedMeal> _meals = [];
  bool _isLoading = false;

  List<PlannedMeal> get meals => _meals;
  bool get isLoading => _isLoading;

  MealPlanProvider() {
    _init();
  }

  Future<void> _init() async {
    // 1. Immediately restore meals from local disk so user's meals NEVER reset
    await _loadFromPrefs();
    // 2. Sync with cloud in background
    await loadMeals();
    try {
      if (Firebase.apps.isNotEmpty) {
        FirebaseAuth.instance.authStateChanges().listen((user) {
          loadMeals();
        });
      }
    } catch (_) {}
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('saved_meals');
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        _meals = decoded
            .map((item) => PlannedMeal.fromJson(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading meals from disk: $e");
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _meals.map((m) => m.toJson()).toList();
      await prefs.setString('saved_meals', jsonEncode(jsonList));
    } catch (e) {
      debugPrint("Error saving meals to disk: $e");
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      if (Firebase.apps.isNotEmpty) return FirebaseFirestore.instance;
    } catch (_) {}
    return null;
  }

  FirebaseAuth? get _auth {
    try {
      if (Firebase.apps.isNotEmpty) return FirebaseAuth.instance;
    } catch (_) {}
    return null;
  }

  CollectionReference? _getCollection() {
    final firestore = _firestore;
    if (firestore == null) return null;

    final user = _auth?.currentUser;
    if (user != null && !user.isAnonymous) {
      return firestore.collection("users").doc(user.uid).collection("mealPlans");
    }
    return firestore.collection("mealPlans");
  }

  List<PlannedMeal> mealsForDay(String day) {
    return _meals.where((m) => m.day.toLowerCase() == day.toLowerCase()).toList();
  }

  int totalCaloriesForDay(String day) {
    int total = 0;
    for (var m in mealsForDay(day)) {
      final digits = m.calories.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.isNotEmpty) {
        total += int.tryParse(digits) ?? 0;
      }
    }
    return total;
  }

  // Load from Firestore with deduplication and accurate sync
  Future<void> loadMeals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final col = _getCollection();
      if (col != null) {
        final snapshot = await col.get().timeout(const Duration(seconds: 4));
        if (snapshot.docs.isNotEmpty) {
          final cloudMeals = snapshot.docs.map((d) => PlannedMeal.fromFirestore(d)).toList();

          // Build a deduplicated map of meals.
          // Cloud documents take precedence.
          final Map<String, PlannedMeal> unifiedMeals = {};

          // First add cloud meals keyed by their document ID
          for (var cm in cloudMeals) {
            unifiedMeals[cm.id] = cm;
          }

          // Then merge local meals:
          // If a local meal has a temporary local ID ('plan_' or 'meal_') but matches an existing
          // cloud meal (same day, mealType, and recipeName), discard the temporary duplicate!
          for (var lm in _meals) {
            if (unifiedMeals.containsKey(lm.id)) {
              // Already present from cloud
              continue;
            }
            final isDuplicateOfCloud = cloudMeals.any(
              (cm) =>
                  cm.day.toLowerCase() == lm.day.toLowerCase() &&
                  cm.mealType.toLowerCase() == lm.mealType.toLowerCase() &&
                  cm.recipeName.toLowerCase() == lm.recipeName.toLowerCase(),
            );
            if (!isDuplicateOfCloud) {
              unifiedMeals[lm.id] = lm;
            }
          }

          _meals = unifiedMeals.values.toList();
          _correctKnownRecipeImages();
          await _saveToPrefs();
          _isLoading = false;
          notifyListeners();
          return;
        } else if (_meals.isEmpty) {
          // Auto-seed default meals only if completely empty
          await _seedInitialMeals(col);
          _correctKnownRecipeImages();
          await _saveToPrefs();
          return;
        }
      }
    } catch (e) {
      debugPrint("Meal plan load note: $e");
    }

    // Fallback default sample meals only if completely empty
    if (_meals.isEmpty) {
      _meals = _getDefaultSampleMeals();
      await _saveToPrefs();
    }
    _correctKnownRecipeImages();
    _isLoading = false;
    notifyListeners();
  }

  // Ensure any cached meals with outdated photos (e.g. Oatmeal Banana Porridge) get the latest verified image
  void _correctKnownRecipeImages() {
    bool changed = false;
    for (int i = 0; i < _meals.length; i++) {
      final m = _meals[i];
      // Match against official mock recipes
      for (var def in MockDataService.defaultRecipes) {
        if (def['name'].toString().toLowerCase() == m.recipeName.toLowerCase()) {
          final officialImg = def['image']?.toString() ?? "";
          if (officialImg.isNotEmpty && m.imageUrl != officialImg) {
            _meals[i] = m.copyWith(imageUrl: officialImg);
            changed = true;
          }
          break;
        }
      }
    }
    if (changed) {
      _saveToPrefs();
    }
  }

  // Add meal - Instant local update + await Firestore document ID so it never doubles on restart!
  Future<void> addMeal(PlannedMeal meal) async {
    // 1. Check if identical meal is already in local list for this day & mealType
    final existingIdx = _meals.indexWhere(
      (m) =>
          m.day.toLowerCase() == meal.day.toLowerCase() &&
          m.mealType.toLowerCase() == meal.mealType.toLowerCase() &&
          m.recipeName.toLowerCase() == meal.recipeName.toLowerCase(),
    );

    if (existingIdx != -1) {
      // Meal already scheduled for this slot, update it instead of creating a clone
      _meals[existingIdx] = meal;
      notifyListeners();
      await _saveToPrefs();
      return;
    }

    // 2. Immediately add to local state and persist to disk in 0ms
    _meals.insert(0, meal);
    notifyListeners();
    await _saveToPrefs();

    // 3. Persist to Firestore and update the meal's ID with the real Firestore ID
    try {
      final col = _getCollection();
      if (col != null) {
        final docRef = await col.add(meal.toMap()).timeout(const Duration(seconds: 4));
        final idx = _meals.indexWhere((m) => m.id == meal.id);
        if (idx != -1) {
          _meals[idx] = meal.copyWith(id: docRef.id);
          await _saveToPrefs();
        }
      }
    } catch (e) {
      debugPrint("Firestore addMeal note (saved locally): $e");
    }
  }

  // Toggle meal completion
  Future<void> toggleCompleted(PlannedMeal meal) async {
    final newStatus = !meal.isCompleted;
    final index = _meals.indexWhere((m) => m.id == meal.id);
    if (index != -1) {
      _meals[index] = meal.copyWith(isCompleted: newStatus);
      notifyListeners();
      await _saveToPrefs();
    }

    try {
      final col = _getCollection();
      if (col != null && !meal.id.startsWith("sample_") && !meal.id.startsWith("meal_") && !meal.id.startsWith("plan_")) {
        col.doc(meal.id).update({'isCompleted': newStatus}).catchError((_) {});
      }
    } catch (e) {
      debugPrint("Toggle meal status note: $e");
    }
  }

  // Delete meal
  Future<void> deleteMeal(String id) async {
    _meals.removeWhere((m) => m.id == id);
    notifyListeners();
    await _saveToPrefs();

    try {
      final col = _getCollection();
      if (col != null && !id.startsWith("sample_") && !id.startsWith("meal_") && !id.startsWith("plan_")) {
        col.doc(id).delete().catchError((_) {});
      }
    } catch (e) {
      debugPrint("Delete meal note: $e");
    }
  }

  Future<void> _seedInitialMeals(CollectionReference col) async {
    final defaults = _getDefaultSampleMeals();
    for (var m in defaults) {
      try {
        await col.add(m.toMap());
      } catch (_) {}
    }
    final snap = await col.get();
    _meals = snap.docs.map((d) => PlannedMeal.fromFirestore(d)).toList();
    _isLoading = false;
    notifyListeners();
  }

  List<PlannedMeal> _getDefaultSampleMeals() {
    return [
      PlannedMeal(
        id: "sample_1",
        day: "Mon",
        mealType: "Breakfast",
        recipeName: "Oatmeal Banana Porridge",
        time: "08:00 AM",
        calories: "290 Cal",
        imageUrl:
            "https://images.unsplash.com/photo-1584776296944-ab6fb57b0bdd?auto=format&fit=crop&w=400&q=80",
      ),
      PlannedMeal(
        id: "sample_2",
        day: "Mon",
        mealType: "Lunch",
        recipeName: "Grilled Chicken Salad",
        time: "01:00 PM",
        calories: "250 Cal",
        imageUrl:
            "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80",
      ),
      PlannedMeal(
        id: "sample_3",
        day: "Mon",
        mealType: "Dinner",
        recipeName: "Shrimp Kale Power Bowl",
        time: "07:30 PM",
        calories: "320 Cal",
        imageUrl:
            "https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=400&q=80",
      ),
      PlannedMeal(
        id: "sample_4",
        day: "Tue",
        mealType: "Breakfast",
        recipeName: "Berry Chia Pudding",
        time: "08:30 AM",
        calories: "210 Cal",
        imageUrl:
            "https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=400&q=80",
      ),
      PlannedMeal(
        id: "sample_5",
        day: "Tue",
        mealType: "Lunch",
        recipeName: "Crispy Mushroom Salad",
        time: "12:30 PM",
        calories: "180 Cal",
        imageUrl:
            "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=400&q=80",
      ),
      PlannedMeal(
        id: "sample_6",
        day: "Wed",
        mealType: "Lunch",
        recipeName: "Thai Green Noodle Salad",
        time: "01:15 PM",
        calories: "340 Cal",
        imageUrl:
            "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=400&q=80",
      ),
    ];
  }

  static MealPlanProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<MealPlanProvider>(context, listen: listen);
  }
}