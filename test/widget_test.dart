import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app2/Provider/auth_provider.dart';
import 'package:recipe_app2/Provider/meal_plan_provider.dart';
import 'package:recipe_app2/Provider/quantity.dart';
import 'package:recipe_app2/Widget/banner.dart';
import 'package:recipe_app2/models/recipe_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('QuantityProvider Servings Scaling Tests', () {
    test('Initial servings count is 1 and scales correctly', () {
      final provider = QuantityProvider();
      expect(provider.currentNumber, 1);

      provider.setBaseIngredientAmounts([100.0, 50.0, 20.0]);
      expect(provider.updateIngredientAmounts, ["100.0", "50.0", "20.0"]);

      // Increase servings to 2
      provider.increaseQuantity();
      expect(provider.currentNumber, 2);
      expect(provider.updateIngredientAmounts, ["200.0", "100.0", "40.0"]);

      // Increase servings to 3
      provider.increaseQuantity();
      expect(provider.currentNumber, 3);
      expect(provider.updateIngredientAmounts, ["300.0", "150.0", "60.0"]);

      // Decrease servings to 2
      provider.decreaseQuantity();
      expect(provider.currentNumber, 2);
      expect(provider.updateIngredientAmounts, ["200.0", "100.0", "40.0"]);

      // Decrease servings to 1 (minimum allowed)
      provider.decreaseQuantity();
      expect(provider.currentNumber, 1);

      // Decreasing further should not drop below 1
      provider.decreaseQuantity();
      expect(provider.currentNumber, 1);
    });
  });

  group('RecipeModel Serialization Tests', () {
    test('RecipeModel converts to and from map properly', () {
      final recipe = RecipeModel(
        id: "recipe_1",
        name: "Grilled Chicken Salad",
        image: "https://example.com/salad.jpg",
        cal: "250",
        time: "20",
        rate: "4.8",
        reviews: "42",
        category: "Salads",
        ingredientsAmount: [200.0, 50.0],
        ingredientsName: ["Chicken", "Lettuce"],
        ingredientsImage: ["https://example.com/c.jpg", "https://example.com/l.jpg"],
      );

      final map = recipe.toMap();
      expect(map['name'], "Grilled Chicken Salad");
      expect(map['cal'], "250");

      final reconstructed = RecipeModel.fromMap(map, "recipe_1");
      expect(reconstructed.name, recipe.name);
      expect(reconstructed.ingredientsAmount, [200.0, 50.0]);
      expect(reconstructed.ingredientsName.length, 2);
    });
  });

  group('AppAuthProvider Guest Login Tests', () {
    test('signInAsGuest instantly authenticates and signOut resets state', () async {
      final authProvider = AppAuthProvider();

      // Sign in as Guest
      final success = await authProvider.signInAsGuest();
      expect(success, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.isGuest, true);
      expect(authProvider.currentUser!.displayName, "Guest Chef");

      // Sign out
      await authProvider.signOut();
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, isNull);
    });
  });

  group('MealPlanProvider Logic Tests', () {
    test('Meals can be added, queried by day, and calories computed', () async {
      final mealProvider = MealPlanProvider();

      final testMeal = PlannedMeal(
        id: "test_meal_1",
        day: "Mon",
        mealType: "Lunch",
        recipeName: "Grilled Chicken Salad",
        time: "12:30 PM",
        calories: "250 Cal",
        imageUrl: "https://example.com/salad.jpg",
      );

      await mealProvider.addMeal(testMeal);

      final mondayMeals = mealProvider.mealsForDay("Mon");
      expect(mondayMeals.any((m) => m.recipeName == "Grilled Chicken Salad"), true);
      expect(mealProvider.totalCaloriesForDay("Mon") >= 250, true);

      // Toggle completed
      await mealProvider.toggleCompleted(testMeal);
      final updated = mealProvider.mealsForDay("Mon").firstWhere((m) => m.id == "test_meal_1");
      expect(updated.isCompleted, true);

      // Delete meal
      await mealProvider.deleteMeal("test_meal_1");
      expect(mealProvider.mealsForDay("Mon").any((m) => m.id == "test_meal_1"), false);

      // Clear all meals for day
      await mealProvider.clearMealsForDay("Mon");
      expect(mealProvider.mealsForDay("Mon").isEmpty, true);
    });
  });

  group('BannerToExplore Tests', () {
    testWidgets('Explore button triggers onExplore callback', (tester) async {
      bool explored = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerToExplore(
              onExplore: () {
                explored = true;
              },
            ),
          ),
        ),
      );

      final exploreBtn = find.text("Explore");
      expect(exploreBtn, findsOneWidget);

      await tester.tap(exploreBtn);
      await tester.pump();
      expect(explored, true);
    });
  });
}

