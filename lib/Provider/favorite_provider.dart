import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> get favorites => _favoriteIds;

  FavoriteProvider() {
    loadFavorites();
    // Listen to auth state changes to reload favorites per user
    _auth.authStateChanges().listen((user) {
      loadFavorites();
    });
  }

  // Helper collection reference for current user or default collection
  CollectionReference _getFavoriteCollection() {
    final user = _auth.currentUser;
    if (user != null && !user.isAnonymous) {
      return _firestore.collection("users").doc(user.uid).collection("userFavorite");
    }
    return _firestore.collection("userFavorite");
  }

  // Toggle favorite state
  Future<void> toggleFavorite(dynamic product) async {
    final String productId = (product is DocumentSnapshot)
        ? product.id
        : product.toString();

    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      notifyListeners();
      await _removeFavorite(productId);
    } else {
      _favoriteIds.add(productId);
      notifyListeners();
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
      await _getFavoriteCollection().doc(productId).set({
        'isFavorite': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error adding favorite to Firestore: $e");
    }
  }

  // Remove favorite from Firestore
  Future<void> _removeFavorite(String productId) async {
    try {
      await _getFavoriteCollection().doc(productId).delete();
    } catch (e) {
      debugPrint("Error removing favorite from Firestore: $e");
    }
  }

  // Load favorites from Firestore
  Future<void> loadFavorites() async {
    try {
      final snapshot = await _getFavoriteCollection().get();
      _favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Note: Loading favorites locally (Firestore not ready or offline: $e)");
    }
  }

  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(
      context,
      listen: listen,
    );
  }
}
