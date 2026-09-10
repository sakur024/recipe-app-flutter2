import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app2/Provider/quantity.dart';
import 'package:recipe_app2/models/recipe_model.dart';

void main() {
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
}
