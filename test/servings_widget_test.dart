import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:recipe_app2/Provider/quantity.dart';
import 'package:recipe_app2/Widget/quantity_increment_decrement.dart';

void main() {
  testWidgets('QuantityIncrementDecrement widget interacts properly with QuantityProvider', (WidgetTester tester) async {
    final quantityProvider = QuantityProvider();
    quantityProvider.setBaseIngredientAmounts([150.0, 75.0]);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: quantityProvider,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer<QuantityProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    QuantityIncrementDecrement(
                      currentNumber: provider.currentNumber,
                      onAdd: () => provider.increaseQuantity(),
                      onRemov: () => provider.decreaseQuantity(),
                    ),
                    Text("Servings: ${provider.currentNumber}"),
                    Text("Amount 0: ${provider.updateIngredientAmounts[0]}g"),
                    Text("Amount 1: ${provider.updateIngredientAmounts[1]}g"),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    // Initial state
    expect(find.text("Servings: 1"), findsOneWidget);
    expect(find.text("Amount 0: 150.0g"), findsOneWidget);
    expect(find.text("Amount 1: 75.0g"), findsOneWidget);

    // Tap '+' to scale to 2 servings
    await tester.tap(find.byIcon(Iconsax.add).first);
    await tester.pump();

    expect(find.text("Servings: 2"), findsOneWidget);
    expect(find.text("Amount 0: 300.0g"), findsOneWidget);
    expect(find.text("Amount 1: 150.0g"), findsOneWidget);

    // Tap '-' to scale back to 1 serving
    await tester.tap(find.byIcon(Iconsax.minus).first);
    await tester.pump();

    expect(find.text("Servings: 1"), findsOneWidget);
    expect(find.text("Amount 0: 150.0g"), findsOneWidget);
    expect(find.text("Amount 1: 75.0g"), findsOneWidget);
  });
}
