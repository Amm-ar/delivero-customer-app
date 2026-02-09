import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Initialize - load saved auth state
  Future<bool> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.loadAuthState();
      if (success) {
        _user = _authService.currentUser;
      }
    } catch (e) {
      _errorMessage = 'Failed to load authentication state';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return _user != null;
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);

      if (result['success']) {
        _user = result['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error. Please check your connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (result['success']) {
        _user = result['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error. Please check your connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      _user = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      // Even if logout fails, clear local state
      _user = null;
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? avatar,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.updateProfile(
        name: name,
        phone: phone,
        avatar: avatar,
      );

      if (result['success']) {
        _user = result['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Profile update failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error. Please check your connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Update user data (for real-time updates)
  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }
}
