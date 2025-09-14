import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/savings_goal.dart';
import '../services/api_service.dart';

class AdminStats {
  final int totalUsers;
  final int totalExpenses;
  final int totalIncomes;
  final int totalGoals;
  final double totalExpenseAmount;
  final double totalIncomeAmount;

  AdminStats({
    required this.totalUsers,
    required this.totalExpenses,
    required this.totalIncomes,
    required this.totalGoals,
    required this.totalExpenseAmount,
    required this.totalIncomeAmount,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalExpenses: json['totalExpenses'] ?? 0,
      totalIncomes: json['totalIncomes'] ?? 0,
      totalGoals: json['totalGoals'] ?? 0,
      totalExpenseAmount: (json['totalExpenseAmount'] ?? 0).toDouble(),
      totalIncomeAmount: (json['totalIncomeAmount'] ?? 0).toDouble(),
    );
  }
}

class AdminProvider with ChangeNotifier {
  List<User> _users = [];
  List<Expense> _allExpenses = [];
  List<Income> _allIncomes = [];
  List<SavingsGoal> _allGoals = [];
  AdminStats? _stats;
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  List<Expense> get allExpenses => _allExpenses;
  List<Income> get allIncomes => _allIncomes;
  List<SavingsGoal> get allGoals => _allGoals;
  AdminStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> loadStats() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.get('/admin/stats');
      _stats = AdminStats.fromJson(response);
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('403') || errorMessage.contains('Access denied')) {
        _setError('Access denied. Admin privileges required.');
      } else if (errorMessage.contains('401') || errorMessage.contains('authorization denied')) {
        _setError('Authentication required. Please login as admin.');
      } else {
        _setError(errorMessage);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUsers() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.get('/admin/users');
      _users = (response as List).map((json) => User.fromJson(json)).toList();
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('403') || errorMessage.contains('Access denied')) {
        _setError('Access denied. Admin privileges required.');
      } else if (errorMessage.contains('401') || errorMessage.contains('authorization denied')) {
        _setError('Authentication required. Please login as admin.');
      } else {
        _setError(errorMessage);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllExpenses() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.get('/admin/expenses');
      _allExpenses = (response as List).map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('403') || errorMessage.contains('Access denied')) {
        _setError('Access denied. Admin privileges required.');
      } else if (errorMessage.contains('401') || errorMessage.contains('authorization denied')) {
        _setError('Authentication required. Please login as admin.');
      } else {
        _setError(errorMessage);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllIncomes() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.get('/admin/incomes');
      _allIncomes = (response as List).map((json) => Income.fromJson(json)).toList();
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('403') || errorMessage.contains('Access denied')) {
        _setError('Access denied. Admin privileges required.');
      } else if (errorMessage.contains('401') || errorMessage.contains('authorization denied')) {
        _setError('Authentication required. Please login as admin.');
      } else {
        _setError(errorMessage);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllGoals() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.get('/admin/goals');
      _allGoals = (response as List).map((json) => SavingsGoal.fromJson(json)).toList();
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('403') || errorMessage.contains('Access denied')) {
        _setError('Access denied. Admin privileges required.');
      } else if (errorMessage.contains('401') || errorMessage.contains('authorization denied')) {
        _setError('Authentication required. Please login as admin.');
      } else {
        _setError(errorMessage);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteUser(String userId) async {
    if (userId.isEmpty) {
      _setError('Invalid user ID');
      return false;
    }
    
    _setLoading(true);
    _setError(null);

    try {
      await ApiService.delete('/admin/users/$userId');
      _users.removeWhere((user) => user.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> makeUserAdmin(String userId) async {
    if (userId.isEmpty) {
      _setError('Invalid user ID');
      return false;
    }
    
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.patch('/admin/users/$userId/make-admin', {});
      if (response != null) {
        final updatedUser = User.fromJson(response);
        final index = _users.indexWhere((user) => user.id == userId);
        if (index != -1) {
          _users[index] = updatedUser;
          notifyListeners();
        }
      }
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> removeAdminPrivileges(String userId) async {
    if (userId.isEmpty) {
      _setError('Invalid user ID');
      return false;
    }
    
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.patch('/admin/users/$userId/remove-admin', {});
      if (response != null) {
        final updatedUser = User.fromJson(response);
        final index = _users.indexWhere((user) => user.id == userId);
        if (index != -1) {
          _users[index] = updatedUser;
          notifyListeners();
        }
      }
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createAdmin(String name, String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      await ApiService.post('/admin/create-admin', {
        'name': name,
        'email': email,
        'password': password,
      });
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _setError(null);
  }
}
