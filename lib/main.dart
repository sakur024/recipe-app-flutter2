import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app2/Provider/auth_provider.dart';
import 'package:recipe_app2/Provider/favorite_provider.dart';
import 'package:recipe_app2/Provider/quantity.dart';
import 'package:recipe_app2/Utils/constants.dart';
import 'package:recipe_app2/Views/auth_gate.dart';
import 'package:recipe_app2/firebase_options.dart';
import 'package:recipe_app2/services/mock_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization note: $e");
  }

  // Launch the UI immediately so the app never hangs on startup
  runApp(const MyApp());

  // Seed Firestore in the background if empty (non-blocking)
  MockDataService.seedFirestoreIfEmpty();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => QuantityProvider()),
      ],
      child: MaterialApp(
        title: 'Recipe App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: kbackgroundColor,
          colorScheme: ColorScheme.fromSeed(seedColor: kprimaryColor),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
