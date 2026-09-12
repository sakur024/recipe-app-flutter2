import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app2/Provider/favorite_provider.dart';
import 'package:recipe_app2/Provider/meal_plan_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('User Isolation Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('FavoriteProvider isolates favorites per user ID', () async {
      final favoriteProvider = FavoriteProvider();

      // User A logs in
      await favoriteProvider.checkUserChanged('user_a');
      expect(favoriteProvider.currentUid, 'user_a');
      expect(favoriteProvider.favorites.isEmpty, true);

      // User A adds a favorite recipe
      await favoriteProvider.toggleFavorite('recipe_pizza_123');
      expect(favoriteProvider.isExist('recipe_pizza_123'), true);
      expect(favoriteProvider.favorites, ['recipe_pizza_123']);

      // User B logs in
      await favoriteProvider.checkUserChanged('user_b');
      expect(favoriteProvider.currentUid, 'user_b');
      // User B must NOT have User A's favorite!
      expect(favoriteProvider.isExist('recipe_pizza_123'), false);
      expect(favoriteProvider.favorites.isEmpty, true);

      // User B adds their own favorite
      await favoriteProvider.toggleFavorite('recipe_salad_456');
      expect(favoriteProvider.favorites, ['recipe_salad_456']);

      // User A logs back in
      await favoriteProvider.checkUserChanged('user_a');
      expect(favoriteProvider.currentUid, 'user_a');
      // User A's favorites restored accurately
      expect(favoriteProvider.isExist('recipe_pizza_123'), true);
      expect(favoriteProvider.isExist('recipe_salad_456'), false);
    });

    test('MealPlanProvider isolates planned meals per user ID', () async {
      final mealProvider = MealPlanProvider();

      // User A logs in
      await mealProvider.checkUserChanged('user_a');
      expect(mealProvider.currentUid, 'user_a');

      final userAMeal = PlannedMeal(
        id: "meal_a_1",
        day: "Fri",
        mealType: "Dinner",
        recipeName: "Special User A Feast",
        time: "08:00 PM",
        calories: "700 Cal",
        imageUrl: "https://example.com/feast.jpg",
      );
      await mealProvider.addMeal(userAMeal);
      expect(mealProvider.mealsForDay("Fri").any((m) => m.recipeName == "Special User A Feast"), true);

      // User B logs in
      await mealProvider.checkUserChanged('user_b');
      expect(mealProvider.currentUid, 'user_b');
      // User B must NOT see User A's custom meal
      expect(mealProvider.mealsForDay("Fri").any((m) => m.recipeName == "Special User A Feast"), false);

      // User A logs back in
      await mealProvider.checkUserChanged('user_a');
      expect(mealProvider.mealsForDay("Fri").any((m) => m.recipeName == "Special User A Feast"), true);
    });
  });
}
