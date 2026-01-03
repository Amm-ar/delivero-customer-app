import 'package:flutter/material.dart';
import '../models/restaurant_model.dart';
import '../services/restaurant_service.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantService _restaurantService = RestaurantService();

  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  
  // Filters
  String? _selectedCuisine;
  String? _searchQuery;

  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _currentPage < _totalPages;
  String? get selectedCuisine => _selectedCuisine;
  String? get searchQuery => _searchQuery;

  // Fetch restaurants
  Future<void> fetchRestaurants({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _restaurants = [];
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _restaurantService.getRestaurants(
      cuisine: _selectedCuisine,
      search: _searchQuery,
      page: _currentPage,
    );

    if (result['success']) {
      if (refresh) {
        _restaurants = result['restaurants'];
      } else {
        _restaurants.addAll(result['restaurants']);
      }
      _totalPages = result['pages'];
      _currentPage++;
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Set cuisine filter
  void setCuisine(String? cuisine) {
    _selectedCuisine = cuisine;
    fetchRestaurants(refresh: true);
  }

  // Set search query
  void setSearch(String? query) {
    _searchQuery = query;
    fetchRestaurants(refresh: true);
  }

  // Clear filters
  void clearFilters() {
    _selectedCuisine = null;
    _searchQuery = null;
    fetchRestaurants(refresh: true);
  }

  // Load more restaurants
  Future<void> loadMore() async {
    if (!_isLoading && hasMore) {
      await fetchRestaurants();
    }
  }
}
