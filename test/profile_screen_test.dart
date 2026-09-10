import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app2/Provider/auth_provider.dart';
import 'package:recipe_app2/Provider/favorite_provider.dart';
import 'package:recipe_app2/Views/profile_screen.dart';

void main() {
  testWidgets('ProfileScreen buttons, toggles, dialogs, and pushes are responsive', (WidgetTester tester) async {
    // Set a large screen size so all items are within view
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final authProvider = AppAuthProvider();
    final favoriteProvider = FavoriteProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider.value(value: favoriteProvider),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    // Verify initial renders
    expect(find.text("Settings & Profile"), findsOneWidget);
    expect(find.text("Cooking Notifications"), findsOneWidget);
    expect(find.text("Measurement Units"), findsOneWidget);
    expect(find.text("Sign Out"), findsOneWidget);

    // 1. Test clicking "Measurement Units" opens dialog
    await tester.ensureVisible(find.text("Measurement Units"));
    await tester.tap(find.text("Measurement Units"));
    await tester.pumpAndSettle();

    expect(find.text("Metric System"), findsOneWidget);
    expect(find.text("Imperial System"), findsOneWidget);

    // Select Imperial System
    await tester.tap(find.text("Imperial System"));
    await tester.pumpAndSettle();

    // Dialog should close and measurement subtitle updates
    expect(find.text("Imperial (oz, cups, °F)"), findsOneWidget);

    // 2. Test clicking "About Recipe App" opens dialog
    await tester.ensureVisible(find.text("About Recipe App"));
    await tester.tap(find.text("About Recipe App"));
    await tester.pumpAndSettle();

    expect(find.text("Awesome!"), findsOneWidget);

    // Tap Awesome to close
    await tester.tap(find.text("Awesome!"));
    await tester.pumpAndSettle();

    // 3. Test clicking "Sign Out" opens confirmation dialog
    await tester.ensureVisible(find.text("Sign Out"));
    await tester.tap(find.text("Sign Out"));
    await tester.pumpAndSettle();

    expect(find.text("Are you sure you want to sign out of Recipe App?"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);

    // Tap cancel
    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();
  });
}
