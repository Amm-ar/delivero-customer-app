import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/restaurant_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, List<CartItem>> _items = {};
  Restaurant? _currentRestaurant;

  Map<String, List<CartItem>> get items => _items;
  Restaurant? get currentRestaurant => _currentRestaurant;
  
  int get itemCount {
    int total = 0;
    _items.forEach((key, value) {
      total += value.fold(0, (sum, item) => sum + item.quantity);
    });
    return total;
  }

  double get subtotal {
    double total = 0;
    _items.forEach((key, value) {
      total += value.fold(0.0, (sum, item) => sum + item.totalPrice);
    });
    return total;
  }

  double get deliveryFee {
    return currentRestaurant?.deliveryFee ?? 0.0;
  }

  double get serviceFee {
    return subtotal * 0.08; // 8% service fee
  }

  double get total {
    return subtotal + deliveryFee + serviceFee;
  }

  List<CartItem> getRestaurantItems(String restaurantId) {
    return _items[restaurantId] ?? [];
  }

  bool get isEmpty => _items.isEmpty;

  // Add item to cart
  void addItem(String restaurantId, Restaurant restaurant, CartItem item) {
    // If switching restaurants, clear cart
    if (_currentRestaurant != null && _currentRestaurant!.id != restaurantId) {
      clearCart();
    }

    _currentRestaurant = restaurant;

    if (_items.containsKey(restaurantId)) {
      // Check if item already exists
      final existingIndex = _items[restaurantId]!.indexWhere(
        (i) => i.menuItemId == item.menuItemId &&
               i.selectedCustomizations.toString() == item.selectedCustomizations.toString(),
      );

      if (existingIndex >= 0) {
        // Increase quantity
        _items[restaurantId]![existingIndex].quantity += item.quantity;
      } else {
        // Add new item
        _items[restaurantId]!.add(item);
      }
    } else {
      _items[restaurantId] = [item];
    }

    notifyListeners();
  }

  // Update quantity
  void updateQuantity(String restaurantId, String itemId, int quantity) {
    if (!_items.containsKey(restaurantId)) return;

    final index = _items[restaurantId]!.indexWhere((i) => i.id == itemId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items[restaurantId]!.removeAt(index);
        if (_items[restaurantId]!.isEmpty) {
          _items.remove(restaurantId);
          _currentRestaurant = null;
        }
      } else {
        _items[restaurantId]![index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  // Remove item
  void removeItem(String restaurantId, String itemId) {
    if (!_items.containsKey(restaurantId)) return;

    _items[restaurantId]!.removeWhere((i) => i.id == itemId);
    if (_items[restaurantId]!.isEmpty) {
      _items.remove(restaurantId);
      _currentRestaurant = null;
    }
    notifyListeners();
  }

  // Clear cart
  void clearCart() {
    _items.clear();
    _currentRestaurant = null;
    notifyListeners();
  }

  // Get order items for API
  List<Map<String, dynamic>> getOrderItems(String restaurantId) {
    final restaurantItems = getRestaurantItems(restaurantId);
    return restaurantItems.map((item) => item.toJson()).toList();
  }
}
