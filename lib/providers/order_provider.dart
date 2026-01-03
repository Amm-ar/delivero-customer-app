import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Create order
  Future<Map<String, dynamic>> createOrder({
    required String restaurantId,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> deliveryAddress,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _orderService.createOrder(
      restaurantId: restaurantId,
      items: items,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
    );

    _isLoading = false;
    
    if (result['success']) {
      // Add to top of orders list
      _orders.insert(0, result['order']);
      notifyListeners();
      return {'success': true, 'order': result['order']};
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return {'success': false, 'message': result['message']};
    }
  }

  // Fetch orders
  Future<void> fetchOrders({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _orderService.getOrders(status: status);

    if (result['success']) {
      _orders = result['orders'];
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId, String reason) async {
    _isLoading = true;
    notifyListeners();

    final result = await _orderService.cancelOrder(orderId, reason);

    _isLoading = false;

    if (result['success']) {
      // Update order in list
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index >= 0) {
        _orders[index] = result['order'];
      }
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Get active orders (not delivered or cancelled)
  List<OrderModel> get activeOrders {
    return _orders.where((o) => 
      o.status != 'delivered' && o.status != 'cancelled'
    ).toList();
  }

  // Get past orders (delivered or cancelled)
  List<OrderModel> get pastOrders {
    return _orders.where((o) => 
      o.status == 'delivered' || o.status == 'cancelled'
    ).toList();
  }
}
