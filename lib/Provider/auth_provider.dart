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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  String? _errorMessage;
  UserProfile? _guestUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  User? get currentFirebaseUser => _auth.currentUser;

  UserProfile? get currentUser {
    if (_auth.currentUser != null) {
      final user = _auth.currentUser!;
      return UserProfile(
        uid: user.uid,
        displayName: user.displayName ?? "Chef User",
        email: user.email,
        photoURL: user.photoURL,
        isGuest: user.isAnonymous,
      );
    }
    return _guestUser;
  }

  bool get isAuthenticated => _auth.currentUser != null || _guestUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google Sign-In
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled sign-in
        _setLoading(false);
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      _guestUser = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = "Google sign-in error: ${e.toString()}";
      _setLoading(false);
      return false;
    }
  }

  // Guest / Anonymous Sign-In
  Future<bool> signInAsGuest() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _auth.signInAnonymously();
      _guestUser = null;
      _setLoading(false);
      return true;
    } catch (e) {
      // Fallback guest session if Firebase anonymous auth is disabled
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
      await _auth.signOut();
    } catch (_) {
      // Ignore if not signed in to Firebase
    }
    _guestUser = null;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  static AppAuthProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<AppAuthProvider>(context, listen: listen);
  }
}
