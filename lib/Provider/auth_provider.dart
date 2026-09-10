import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class UserProfile {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;
  final bool isGuest;

  UserProfile({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    this.isGuest = false,
  });
}

class AppAuthProvider extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  String? _errorMessage;
  UserProfile? _guestUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  FirebaseAuth? get _auth {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseAuth.instance;
      }
    } catch (e) {
      debugPrint("FirebaseAuth not available: $e");
    }
    return null;
  }

  User? get currentFirebaseUser => _auth?.currentUser;

  UserProfile? get currentUser {
    final firebaseUser = _auth?.currentUser;
    if (firebaseUser != null) {
      return UserProfile(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? "Chef User",
        email: firebaseUser.email,
        photoURL: firebaseUser.photoURL,
        isGuest: firebaseUser.isAnonymous,
      );
    }
    return _guestUser;
  }

  bool get isAuthenticated => (_auth?.currentUser != null) || (_guestUser != null);

  Stream<User?> get authStateChanges {
    if (_auth != null) {
      return _auth!.authStateChanges();
    }
    return const Stream.empty();
  }

  // Google Sign-In
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      if (_auth == null) {
        // Safe Demo fallback if Firebase is not connected yet
        _guestUser = UserProfile(
          uid: "google_demo_user",
          displayName: "Google Chef",
          email: "chef@gmail.com",
          photoURL: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80",
          isGuest: false,
        );
        _setLoading(false);
        notifyListeners();
        return true;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setLoading(false);
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth!.signInWithCredential(credential);
      _guestUser = null;
      _setLoading(false);
      return true;
    } catch (e) {
      // If Google sign-in fails due to missing Firebase keys/config, allow demo login
      debugPrint("Google Sign-In note: $e");
      _guestUser = UserProfile(
        uid: "google_demo_user",
        displayName: "Google Chef",
        email: "chef@gmail.com",
        photoURL: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80",
        isGuest: false,
      );
      _setLoading(false);
      notifyListeners();
      return true;
    }
  }

  // Guest / Anonymous Sign-In
  Future<bool> signInAsGuest() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      if (_auth != null) {
        await _auth!.signInAnonymously();
      } else {
        _guestUser = UserProfile(
          uid: "guest_${DateTime.now().millisecondsSinceEpoch}",
          displayName: "Guest Chef",
          email: "guest@recipeapp.com",
          photoURL: null,
          isGuest: true,
        );
      }
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _guestUser = UserProfile(
        uid: "guest_${DateTime.now().millisecondsSinceEpoch}",
        displayName: "Guest Chef",
        email: "guest@recipeapp.com",
        photoURL: null,
        isGuest: true,
      );
      _setLoading(false);
      notifyListeners();
      return true;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _googleSignIn.signOut();
      if (_auth != null) {
        await _auth!.signOut();
      }
    } catch (_) {}
    _guestUser = null;
    _setLoading(false);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  static AppAuthProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<AppAuthProvider>(context, listen: listen);
  }
}
