import '../models/order_model.dart';
import 'api_service.dart';
import '../config/constants.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  // Create order
  Future<Map<String, dynamic>> createOrder({
    required String restaurantId,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> deliveryAddress,
    required String paymentMethod,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.orders,
        data: {
          'restaurant': restaurantId,
          'items': items,
          'deliveryAddress': deliveryAddress,
          'payment': {
            'method': paymentMethod,
          },
        },
      );

      if (response.statusCode == 201 && response.data['success']) {
        return {
          'success': true,
          'order': OrderModel.fromJson(response.data['data']),
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to create order'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get user orders
  Future<Map<String, dynamic>> getOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status;

      final response = await _apiService.get(
        ApiConstants.orders,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success']) {
        final orders = (response.data['data'] as List)
            .map((o) => OrderModel.fromJson(o))
            .toList();

        return {
          'success': true,
          'orders': orders,
          'total': response.data['total'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to load orders'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get single order
  Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      final response = await _apiService.get('${ApiConstants.orders}/$orderId');

      if (response.statusCode == 200 && response.data['success']) {
        return {
          'success': true,
          'order': OrderModel.fromJson(response.data['data']),
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Order not found'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Cancel order
  Future<Map<String, dynamic>> cancelOrder(String orderId, String reason) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.orders}/$orderId/cancel',
        data: {'reason': reason},
      );

      if (response.statusCode == 200 && response.data['success']) {
        return {
          'success': true,
          'order': OrderModel.fromJson(response.data['data']),
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to cancel order'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
