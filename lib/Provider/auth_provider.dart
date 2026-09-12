import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isInitializing = true;
  String? _errorMessage;
  UserProfile? _guestUser;
  UserProfile? _persistedUser;

  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;

  AppAuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      // Do not clobber if an in-memory session was already established
      if (isLoggedIn && _guestUser == null && _persistedUser == null) {
        final uid = prefs.getString('saved_uid') ?? "persisted_user";
        final isGuest = prefs.getBool('is_guest') ?? false;
        final name = prefs.getString('saved_name') ??
            (isGuest ? "Guest Chef" : "Chef User");
        final email = prefs.getString('saved_email');
        final photo = prefs.getString('saved_photo');

        if (isGuest) {
          _guestUser = UserProfile(
            uid: uid,
            displayName: name,
            email: email,
            photoURL: photo,
            isGuest: true,
          );
        } else {
          _persistedUser = UserProfile(
            uid: uid,
            displayName: name,
            email: email,
            photoURL: photo,
            isGuest: false,
          );
        }
      }
    } catch (e) {
      debugPrint("Session restore note: $e");
    }

    _listenToAuth();
    _isInitializing = false;
    notifyListeners();
  }

  void _listenToAuth() {
    try {
      if (Firebase.apps.isNotEmpty) {
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user != null && !user.isAnonymous) {
            _guestUser = null;
            final derivedName =
                _deriveDisplayName(user.displayName, user.email, false);
            _persistedUser = UserProfile(
              uid: user.uid,
              displayName: derivedName,
              email: user.email,
              photoURL: user.photoURL,
              isGuest: false,
            );
            _saveSession(
              user.uid,
              derivedName,
              user.email,
              false,
              photo: user.photoURL,
            );
            notifyListeners();
          } else if (user != null && user.isAnonymous) {
            // Only adopt anonymous user if there is NO real non-guest user
            if (_persistedUser == null || _persistedUser!.isGuest) {
              _saveSession(
                user.uid,
                "Guest Chef",
                "guest@recipeapp.com",
                true,
              );
              notifyListeners();
            }
          }
        });
      }
    } catch (_) {}
  }

  static String _deriveDisplayName(String? name, String? email, bool isAnonymous) {
    if (name != null && name.trim().isNotEmpty) {
      return name.trim();
    }
    if (isAnonymous) {
      return "Guest Chef";
    }
    if (email != null && email.isNotEmpty) {
      final prefix = email.split('@').first;
      final formatted = prefix
          .replaceAll(RegExp(r'[._\-]'), ' ')
          .split(' ')
          .where((w) => w.isNotEmpty)
          .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ')
          .trim();
      if (formatted.isNotEmpty) return formatted;
    }
    return "Gourmet Chef";
  }

  Future<void> _saveSession(
    String uid,
    String? name,
    String? email,
    bool isGuest, {
    String? photo,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_uid', uid);
      if (name != null) await prefs.setString('saved_name', name);
      if (email != null) await prefs.setString('saved_email', email);
      await prefs.setBool('is_guest', isGuest);
      if (photo != null) await prefs.setString('saved_photo', photo);
      await prefs.setBool('is_logged_in', true);
    } catch (e) {
      debugPrint("Session save error: $e");
    }
  }

  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_logged_in');
      await prefs.remove('saved_uid');
      await prefs.remove('saved_name');
      await prefs.remove('saved_email');
      await prefs.remove('is_guest');
      await prefs.remove('saved_photo');
    } catch (e) {
      debugPrint("Session clear error: $e");
    }
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

    // 1. If Firebase has an authenticated non-anonymous user, that takes top priority
    if (firebaseUser != null && !firebaseUser.isAnonymous) {
      final derivedName = _deriveDisplayName(
        firebaseUser.displayName,
        firebaseUser.email,
        false,
      );
      return UserProfile(
        uid: firebaseUser.uid,
        displayName: derivedName,
        email: firebaseUser.email,
        photoURL: firebaseUser.photoURL,
        isGuest: false,
      );
    }

    // 2. If we have a verified non-guest persisted user
    if (_persistedUser != null && !_persistedUser!.isGuest) {
      return _persistedUser;
    }

    // 3. In-memory guest user
    if (_guestUser != null) {
      return _guestUser;
    }

    // 4. Firebase anonymous user
    if (firebaseUser != null && firebaseUser.isAnonymous) {
      return UserProfile(
        uid: firebaseUser.uid,
        displayName: "Guest Chef",
        email: "guest@recipeapp.com",
        photoURL: null,
        isGuest: true,
      );
    }

    // 5. Persisted guest session
    if (_persistedUser != null) {
      return _persistedUser;
    }

    return null;
  }

  bool get isAuthenticated => currentUser != null;

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
          final userCred = await _auth!.signInWithPopup(googleProvider);
          if (userCred.user != null) {
            final derivedName = _deriveDisplayName(
              userCred.user!.displayName,
              userCred.user!.email,
              false,
            );
            _guestUser = null;
            _persistedUser = UserProfile(
              uid: userCred.user!.uid,
              displayName: derivedName,
              email: userCred.user!.email,
              photoURL: userCred.user!.photoURL,
              isGuest: false,
            );
            await _saveSession(
              userCred.user!.uid,
              derivedName,
              userCred.user!.email,
              false,
              photo: userCred.user!.photoURL,
            );
          }
          _setLoading(false);
          notifyListeners();
          return true;
        }
      } else {
        // Android / iOS
        if (_auth?.currentUser?.isAnonymous == true) {
          try {
            await _auth!.signOut();
          } catch (_) {}
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

        if (_auth != null) {
          final userCred = await _auth!.signInWithCredential(credential);
          if (userCred.user != null) {
            final derivedName = _deriveDisplayName(
              userCred.user!.displayName,
              userCred.user!.email,
              false,
            );
            _guestUser = null;
            _persistedUser = UserProfile(
              uid: userCred.user!.uid,
              displayName: derivedName,
              email: userCred.user!.email,
              photoURL: userCred.user!.photoURL,
              isGuest: false,
            );
            await _saveSession(
              userCred.user!.uid,
              derivedName,
              userCred.user!.email,
              false,
              photo: userCred.user!.photoURL,
            );
          }
          _setLoading(false);
          notifyListeners();
          return true;
        } else {
          final derivedName = googleUser.displayName ??
              _deriveDisplayName(null, googleUser.email, false);
          _guestUser = null;
          _persistedUser = UserProfile(
            uid: googleUser.id,
            displayName: derivedName,
            email: googleUser.email,
            photoURL: googleUser.photoUrl,
            isGuest: false,
          );
          await _saveSession(
            googleUser.id,
            derivedName,
            googleUser.email,
            false,
            photo: googleUser.photoUrl,
          );
          _setLoading(false);
          notifyListeners();
          return true;
        }
      }

      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint("Google Sign-In note: $e");
      final errString = e.toString();
      if (errString.contains("ApiException: 10") ||
          errString.contains("10:") ||
          errString.contains("developer error")) {
        _errorMessage =
            "Google Sign-In requires SHA-1 fingerprint to be registered in Firebase Console. Please sign in with Email/Password or Guest Chef!";
      } else if (errString.contains("ApiException: 12500") ||
          errString.contains("12500:")) {
        _errorMessage =
            "Google Sign-In failed (code 12500). Please check your Google Play Services or sign in with Email!";
      } else {
        _errorMessage =
            errString.replaceFirst(RegExp(r'\[.*?\]'), '').trim();
      }
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Email & Password Sign-In
  Future<bool> signInWithEmailPassword(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    if (_auth?.currentUser?.isAnonymous == true) {
      try {
        await _auth!.signOut();
      } catch (_) {}
    }

    try {
      if (_auth != null) {
        try {
          final cred = await _auth!.signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
          _guestUser = null;
          if (cred.user != null) {
            final derivedName = _deriveDisplayName(
              cred.user!.displayName,
              cred.user!.email,
              false,
            );
            _persistedUser = UserProfile(
              uid: cred.user!.uid,
              displayName: derivedName,
              email: cred.user!.email,
              photoURL: cred.user!.photoURL,
              isGuest: false,
            );
            await _saveSession(
              cred.user!.uid,
              derivedName,
              cred.user!.email,
              false,
              photo: cred.user!.photoURL,
            );
          }
          _setLoading(false);
          notifyListeners();
          return true;
        } on FirebaseAuthException catch (fae) {
          if (fae.code == 'operation-not-allowed' ||
              fae.code == 'network-request-failed') {
            final derivedName = _deriveDisplayName(null, email, false);
            _guestUser = null;
            _persistedUser = UserProfile(
              uid: "user_${email.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}",
              displayName: derivedName,
              email: email.trim(),
              isGuest: false,
            );
            await _saveSession(
                _persistedUser!.uid, derivedName, email.trim(), false);
            _setLoading(false);
            notifyListeners();
            return true;
          }
          rethrow;
        }
      } else {
        final derivedName = _deriveDisplayName(null, email, false);
        _guestUser = null;
        _persistedUser = UserProfile(
          uid: "user_${email.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}",
          displayName: derivedName,
          email: email.trim(),
          isGuest: false,
        );
        await _saveSession(_persistedUser!.uid, derivedName, email.trim(), false);
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

    if (_auth?.currentUser?.isAnonymous == true) {
      try {
        await _auth!.signOut();
      } catch (_) {}
    }

    try {
      if (_auth != null) {
        try {
          final credential = await _auth!.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
          if (credential.user != null && name.isNotEmpty) {
            await credential.user!.updateDisplayName(name.trim());
          }
          _guestUser = null;
          final derivedName = name.trim().isNotEmpty
              ? name.trim()
              : _deriveDisplayName(null, email, false);
          if (credential.user != null) {
            _persistedUser = UserProfile(
              uid: credential.user!.uid,
              displayName: derivedName,
              email: credential.user!.email,
              photoURL: credential.user!.photoURL,
              isGuest: false,
            );
            await _saveSession(
              credential.user!.uid,
              derivedName,
              credential.user!.email,
              false,
            );
          }
          _setLoading(false);
          notifyListeners();
          return true;
        } on FirebaseAuthException catch (fae) {
          if (fae.code == 'operation-not-allowed' ||
              fae.code == 'network-request-failed') {
            final derivedName = name.trim().isNotEmpty
                ? name.trim()
                : _deriveDisplayName(null, email, false);
            _guestUser = null;
            _persistedUser = UserProfile(
              uid: "user_${email.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}",
              displayName: derivedName,
              email: email.trim(),
              isGuest: false,
            );
            await _saveSession(
                _persistedUser!.uid, derivedName, email.trim(), false);
            _setLoading(false);
            notifyListeners();
            return true;
          }
          rethrow;
        }
      } else {
        final derivedName = name.trim().isNotEmpty
            ? name.trim()
            : _deriveDisplayName(null, email, false);
        _guestUser = null;
        _persistedUser = UserProfile(
          uid: "user_${email.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}",
          displayName: derivedName,
          email: email.trim(),
          isGuest: false,
        );
        await _saveSession(_persistedUser!.uid, derivedName, email.trim(), false);
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
    final guestId = "guest_${DateTime.now().millisecondsSinceEpoch}";
    _guestUser = UserProfile(
      uid: guestId,
      displayName: "Guest Chef",
      email: "guest@recipeapp.com",
      photoURL: null,
      isGuest: true,
    );
    _persistedUser = null;
    await _saveSession(guestId, "Guest Chef", "guest@recipeapp.com", true);
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
    await _clearSession();
    try {
      if (!kIsWeb) {
        try {
          await _googleSignIn
              .disconnect()
              .timeout(const Duration(seconds: 2), onTimeout: () => null);
        } catch (_) {}
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
    _persistedUser = null;
    _setLoading(false);
    notifyListeners();
  }

  // Update Profile Name
  Future<void> updateProfileName(String newName) async {
    final current = currentUser;
    if (current != null) {
      if (_auth?.currentUser != null && !_auth!.currentUser!.isAnonymous) {
        try {
          await _auth!.currentUser!.updateDisplayName(newName);
        } catch (_) {}
      }
      final updated = UserProfile(
        uid: current.uid,
        displayName: newName,
        email: current.email,
        photoURL: current.photoURL,
        isGuest: current.isGuest,
      );
      if (current.isGuest) {
        _guestUser = updated;
      } else {
        _persistedUser = updated;
      }
      await _saveSession(
        current.uid,
        newName,
        current.email,
        current.isGuest,
        photo: current.photoURL,
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
