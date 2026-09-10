import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app2/Provider/auth_provider.dart';
import 'package:recipe_app2/Utils/constants.dart';
import 'package:recipe_app2/Views/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization note: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
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
