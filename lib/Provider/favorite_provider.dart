import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  String? _activeUid;

  List<String> get favorites => _favoriteIds;

  String get currentUid {
    if (_activeUid != null && _activeUid!.isNotEmpty) {
      return _activeUid!;
    }
    final user = _auth?.currentUser;
    if (user != null && !user.isAnonymous) {
      return user.uid;
    }
    return 'guest';
  }

  Future<void>? _initFuture;

  FavoriteProvider() {
    _initFuture = _initFavorites();
    try {
      if (Firebase.apps.isNotEmpty) {
        FirebaseAuth.instance.authStateChanges().listen((user) {
          checkUserChanged(user?.uid);
        });
      }
    } catch (_) {}
  }

  Future<void> ensureInitialized() => _initFuture ?? Future.value();

  Future<void> _initFavorites() async {
    // 1. Instantly restore from local device storage for the current user
    await _loadFromPrefs();
    // 2. Sync with cloud in background
    await loadFavorites();
  }

  String _getStorageKey() {
    return 'saved_favorites_$currentUid';
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_getStorageKey());
      if (saved != null) {
        _favoriteIds = saved;
      } else {
        _favoriteIds = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading favorites from disk: $e");
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_getStorageKey(), _favoriteIds);
    } catch (e) {
      debugPrint("Error saving favorites to disk: $e");
    }
  }

  /// Verifies if user changed, and cleanly resets in-memory data for the new account
  Future<void> checkUserChanged(String? newUid) async {
    await ensureInitialized();
    final resolved = (newUid != null && newUid.isNotEmpty) ? newUid : 'guest';
    if (_activeUid != resolved) {
      _activeUid = resolved;
      await onUserChanged();
    }
  }

  /// Clears in-memory favorites and reloads for the newly active user
  Future<void> onUserChanged() async {
    _favoriteIds = [];
    notifyListeners();
    await _loadFromPrefs();
    await loadFavorites();
  }

  FirebaseFirestore? get _firestore {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (_) {}
    return null;
  }

  FirebaseAuth? get _auth {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseAuth.instance;
      }
    } catch (_) {}
    return null;
  }

  // Helper collection reference for current user
  CollectionReference? _getFavoriteCollection() {
    final firestore = _firestore;
    if (firestore == null) return null;

    final uid = currentUid;
    if (uid != 'guest') {
      return firestore.collection("users").doc(uid).collection("userFavorite");
    }
    return null; // Guest favorites remain local on device
  }

  // Toggle favorite state
  Future<void> toggleFavorite(dynamic product) async {
    final String productId = (product is DocumentSnapshot)
        ? product.id
        : product.toString();

    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      notifyListeners();
      await _saveToPrefs();
      await _removeFavorite(productId);
    } else {
      _favoriteIds.add(productId);
      notifyListeners();
      await _saveToPrefs();
      await _addFavorite(productId);
    }
  }

  // Check if a product is favorited
  bool isExist(dynamic product) {
    final String productId = (product is DocumentSnapshot)
        ? product.id
        : product.toString();
    return _favoriteIds.contains(productId);
  }

  // Add favorite to Firestore
  Future<void> _addFavorite(String productId) async {
    try {
      final col = _getFavoriteCollection();
      if (col != null) {
        await col.doc(productId).set({
          'isFavorite': true,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("Favorite stored locally (Firestore sync note: $e)");
    }
  }

  // Remove favorite from Firestore
  Future<void> _removeFavorite(String productId) async {
    try {
      final col = _getFavoriteCollection();
      if (col != null) {
        await col.doc(productId).delete();
      }
    } catch (e) {
      debugPrint("Favorite removed locally (Firestore sync note: $e)");
    }
  }

  // Load favorites from Firestore
  Future<void> loadFavorites() async {
    try {
      final col = _getFavoriteCollection();
      if (col != null) {
        final snapshot = await col.get().timeout(const Duration(seconds: 3));
        final cloudIds = snapshot.docs.map((doc) => doc.id).toList();
        _favoriteIds = {..._favoriteIds, ...cloudIds}.toList();
        await _saveToPrefs();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Favorites loaded locally (Firestore sync note: $e)");
    }
  }

  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(
      context,
      listen: listen,
    );
  }
}
