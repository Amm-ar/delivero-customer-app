import '../models/restaurant_model.dart';
import '../models/menu_item_model.dart';
import 'api_service.dart';
import '../config/constants.dart';

class RestaurantService {
  final ApiService _apiService = ApiService();

  // Get all restaurants with filters
  Future<Map<String, dynamic>> getRestaurants({
    String? cuisine,
    String? priceRange,
    String? search,
    double? lat,
    double? lng,
    double radius = 10,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'radius': radius,
      };

      if (cuisine != null) queryParams['cuisine'] = cuisine;
      if (priceRange != null) queryParams['priceRange'] = priceRange;
      if (search != null) queryParams['search'] = search;
      if (lat != null) queryParams['lat'] = lat;
      if (lng != null) queryParams['lng'] = lng;

      final response = await _apiService.get(
        ApiConstants.restaurants,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success']) {
        final restaurants = (response.data['data'] as List)
            .map((r) => Restaurant.fromJson(r))
            .toList();

        return {
          'success': true,
          'restaurants': restaurants,
          'total': response.data['total'],
          'pages': response.data['pages'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to load restaurants'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get single restaurant
  Future<Map<String, dynamic>> getRestaurant(String id) async {
    try {
      final response = await _apiService.get('${ApiConstants.restaurants}/$id');

      if (response.statusCode == 200 && response.data['success']) {
        return {
          'success': true,
          'restaurant': Restaurant.fromJson(response.data['data']),
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Restaurant not found'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get restaurant menu
  Future<Map<String, dynamic>> getMenu(String restaurantId, {
    String? category,
    String? tags,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (tags != null) queryParams['tags'] = tags;
      if (search != null) queryParams['search'] = search;

      final response = await _apiService.get(
        '${ApiConstants.restaurants}/$restaurantId/menu',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success']) {
        final menuItems = (response.data['data'] as List)
            .map((m) => MenuItem.fromJson(m))
            .toList();

        return {
          'success': true,
          'menuItems': menuItems,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to load menu'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
