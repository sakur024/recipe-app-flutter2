import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];

  List<String> get favorites => _favoriteIds;

  FavoriteProvider() {
    _initFavorites();
    try {
      if (Firebase.apps.isNotEmpty) {
        FirebaseAuth.instance.authStateChanges().listen((user) {
          loadFavorites();
        });
      }
    } catch (_) {}
  }

  Future<void> _initFavorites() async {
    // 1. Instantly restore from local device storage so favorites NEVER reset
    await _loadFromPrefs();
    // 2. Sync with cloud in background
    await loadFavorites();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('saved_favorites');
      if (saved != null) {
        _favoriteIds = saved;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading favorites from disk: $e");
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('saved_favorites', _favoriteIds);
    } catch (e) {
      debugPrint("Error saving favorites to disk: $e");
    }
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

  // Helper collection reference for current user or default collection
  CollectionReference? _getFavoriteCollection() {
    final firestore = _firestore;
    if (firestore == null) return null;

    final user = _auth?.currentUser;
    if (user != null && !user.isAnonymous) {
      return firestore.collection("users").doc(user.uid).collection("userFavorite");
    }
    return firestore.collection("userFavorite");
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
        if (snapshot.docs.isNotEmpty) {
          final cloudIds = snapshot.docs.map((doc) => doc.id).toList();
          final merged = {..._favoriteIds, ...cloudIds}.toList();
          _favoriteIds = merged;
          await _saveToPrefs();
          notifyListeners();
        }
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
