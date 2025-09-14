import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get initialized => _initialized;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    if (_initialized) return _user != null;
    
    _setLoading(true);
    try {
      final token = await ApiService.getToken();
      if (token != null && token.isNotEmpty) {
        // Token exists, but we need to validate it and get user info
        try {
          // Try to make an authenticated request to validate token
          final response = await ApiService.get('/auth/me');
          _user = User.fromJson(response);
          _initialized = true;
          _setLoading(false);
          return true;
        } catch (e) {
          print('Token validation failed: $e');
          // Token is invalid, clear it
          await logout();
          _setLoading(false);
          return false;
        }
      }
      _initialized = true;
      _setLoading(false);
      return false;
    } catch (e) {
      print('Auth check error: $e');
      _initialized = true;
      _setLoading(false);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.login(email, password);
      print('Login response: $response'); // Debug log
      
      if (response['success'] == true) {
        _user = User.fromJson(response['user']);
        _initialized = true;
        print('User set: ${_user?.email}, isAdmin: ${_user?.isAdmin}'); // Debug log
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('Login error: $e'); // Debug log
      _setError('Login failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final authResponse = await ApiService.register(name, email, password);
      _user = authResponse.user;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    _user = null;
    _initialized = true;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }
}
