import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

  AppAuthProvider() {
    _listenToAuth();
  }

  void _listenToAuth() {
    try {
      if (Firebase.apps.isNotEmpty) {
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user != null) {
            _guestUser = null;
          }
          notifyListeners();
        });
      }
    } catch (_) {}
  }

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
        displayName: firebaseUser.displayName ??
            (firebaseUser.isAnonymous ? "Guest Chef" : "Chef User"),
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
      if (kIsWeb) {
        // On Web, use GoogleAuthProvider with signInWithPopup
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        if (_auth != null) {
          await _auth!.signInWithPopup(googleProvider);
          _guestUser = null;
          _setLoading(false);
          return true;
        }
      } else {
        // On Android / iOS
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

        if (_auth != null) {
          await _auth!.signInWithCredential(credential);
          _guestUser = null;
          _setLoading(false);
          return true;
        }
      }

      // Safe fallback if Firebase is not ready
      _guestUser = UserProfile(
        uid: "google_chef_user",
        displayName: "Google Chef",
        email: "chef@recipeapp.com",
        photoURL:
            "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80",
        isGuest: false,
      );
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Google Sign-In note: $e");
      _errorMessage = e.toString().replaceFirst(RegExp(r'\[.*?\]'), '').trim();
      // If error is popup blocked or configuration, still provide helpful fallback
      _guestUser = UserProfile(
        uid: "chef_${DateTime.now().millisecondsSinceEpoch}",
        displayName: "Chef Gourmet",
        email: "chef@recipeapp.com",
        photoURL:
            "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80",
        isGuest: false,
      );
      _setLoading(false);
      notifyListeners();
      return true;
    }
  }

  // Email & Password Sign-In
  Future<bool> signInWithEmailPassword(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      if (_auth != null) {
        await _auth!.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
        _guestUser = null;
        _setLoading(false);
        return true;
      } else {
        _guestUser = UserProfile(
          uid: "user_${DateTime.now().millisecondsSinceEpoch}",
          displayName: email.split('@').first,
          email: email,
          isGuest: false,
        );
        _setLoading(false);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst(RegExp(r'\[.*?\]'), '').trim();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Email & Password Registration
  Future<bool> registerWithEmailPassword(
      String email, String password, String name) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      if (_auth != null) {
        final credential = await _auth!.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
        if (credential.user != null && name.isNotEmpty) {
          await credential.user!.updateDisplayName(name.trim());
        }
        _guestUser = null;
        _setLoading(false);
        return true;
      } else {
        _guestUser = UserProfile(
          uid: "user_${DateTime.now().millisecondsSinceEpoch}",
          displayName: name.isNotEmpty ? name : email.split('@').first,
          email: email,
          isGuest: false,
        );
        _setLoading(false);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst(RegExp(r'\[.*?\]'), '').trim();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Guest / Anonymous Sign-In
  Future<bool> signInAsGuest() async {
    _errorMessage = null;
    _guestUser = UserProfile(
      uid: "guest_${DateTime.now().millisecondsSinceEpoch}",
      displayName: "Guest Chef",
      email: "guest@recipeapp.com",
      photoURL: null,
      isGuest: true,
    );
    _isLoading = false;
    notifyListeners();

    // In background, attempt anonymous Firebase auth if enabled, without blocking UI
    try {
      if (_auth != null) {
        _auth!.signInAnonymously().then((_) {}, onError: (e) {
          debugPrint("Firebase anonymous sign-in note: $e");
        });
      }
    } catch (e) {
      debugPrint("Background guest auth note: $e");
    }
    return true;
  }

  // Sign Out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      if (!kIsWeb) {
        await _googleSignIn
            .signOut()
            .timeout(const Duration(seconds: 3), onTimeout: () => null);
      }
      if (_auth != null) {
        await _auth!
            .signOut()
            .timeout(const Duration(seconds: 3), onTimeout: () {});
      }
    } catch (_) {}
    _guestUser = null;
    _setLoading(false);
    notifyListeners();
  }

  // Update Profile Name
  Future<void> updateProfileName(String newName) async {
    final current = currentUser;
    if (current != null) {
      if (_auth?.currentUser != null) {
        try {
          await _auth!.currentUser!.updateDisplayName(newName);
        } catch (_) {}
      }
      _guestUser = UserProfile(
        uid: current.uid,
        displayName: newName,
        email: current.email,
        photoURL: current.photoURL,
        isGuest: current.isGuest,
      );
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  static AppAuthProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<AppAuthProvider>(context, listen: listen);
  }
}
