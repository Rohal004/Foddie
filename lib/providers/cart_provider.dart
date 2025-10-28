import 'package:flutter/material.dart';
import '../models/food_item.dart';

class CartProvider with ChangeNotifier {
  // Map of item id -> FoodItem
  final Map<String, FoodItem> _items = {};
  // Map of item id -> quantity
  final Map<String, int> _quantities = {};

  Map<String, FoodItem> get items => _items;

  int quantityFor(String id) => _quantities[id] ?? 0;

  double get total => _items.values.fold(0.0, (sum, item) {
    final qty = _quantities[item.id] ?? 1;
    return sum + item.price * qty;
  });

  void addToCart(FoodItem food) {
    _items.putIfAbsent(food.id, () => food);
    _quantities.update(food.id, (q) => q + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void increaseQuantity(String id) {
    if (!_items.containsKey(id)) return;
    _quantities.update(id, (q) => q + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void decreaseQuantity(String id) {
    if (!_items.containsKey(id)) return;
    final q = (_quantities[id] ?? 1) - 1;
    if (q <= 0) {
      _items.remove(id);
      _quantities.remove(id);
    } else {
      _quantities[id] = q;
    }
    notifyListeners();
  }

  void removeFromCart(String id) {
    _items.remove(id);
    _quantities.remove(id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _quantities.clear();
    notifyListeners();
  }
}
