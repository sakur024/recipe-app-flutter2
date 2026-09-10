import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuantityProvider extends ChangeNotifier {
  int _currentNumber = 1;
  List<double> _baseIngredientAmounts = [];

  int get currentNumber => _currentNumber;

  // Set initial ingredient amounts when viewing a recipe
  void setBaseIngredientAmounts(List<double> amounts) {
    _baseIngredientAmounts = amounts;
    _currentNumber = 1;
    notifyListeners();
  }

  // Update ingredient amounts based on the quantity/servings multiplier
  List<String> get updateIngredientAmounts {
    return _baseIngredientAmounts
        .map<String>((amount) => (amount * _currentNumber).toStringAsFixed(1))
        .toList();
  }

  // Increase servings count
  void increaseQuantity() {
    _currentNumber++;
    notifyListeners();
  }

  // Decrease servings count (minimum 1)
  void decreaseQuantity() {
    if (_currentNumber > 1) {
      _currentNumber--;
      notifyListeners();
    }
  }

  // Backward compatibility alias matching tutorial spelling
  void decreaseQuanity() => decreaseQuantity();

  static QuantityProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<QuantityProvider>(context, listen: listen);
  }
}
