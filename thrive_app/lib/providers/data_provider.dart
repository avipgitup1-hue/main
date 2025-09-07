import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/savings_goal.dart';
import '../models/dashboard_data.dart';
import '../services/api_service.dart';

class DataProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<Income> _incomes = [];
  List<SavingsGoal> _savingsGoals = [];
  DashboardData? _dashboardData;
  PredictionData? _predictionData;
  List<CategoryData> _categoryData = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  List<Expense> get expenses => _expenses;
  List<Income> get incomes => _incomes;
  List<SavingsGoal> get savingsGoals => _savingsGoals;
  DashboardData? get dashboardData => _dashboardData;
  PredictionData? get predictionData => _predictionData;
  List<CategoryData> get categoryData => _categoryData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(String operation, dynamic error) {
    _error = 'Failed to $operation: ${error.toString()}';
    _isLoading = false;
    notifyListeners();
  }

  void clearLocalData() {
    _expenses.clear();
    _incomes.clear();
    _savingsGoals.clear();
    _dashboardData = null;
    _error = null;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  // Expense methods
  Future<void> loadExpenses() async {
    _setLoading(true);
    _setError(null);

    try {
      _expenses = await ApiService.getExpenses();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  Future<bool> createExpense(Expense expense) async {
    _setLoading(true);
    _setError(null);

    try {
      final newExpense = await ApiService.createExpense(expense);
      _expenses.insert(0, newExpense);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateExpense(String id, Expense expense) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedExpense = await ApiService.updateExpense(id, expense);
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteExpense(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      await ApiService.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Income methods
  Future<void> loadIncomes() async {
    _setLoading(true);
    _setError(null);

    try {
      _incomes = await ApiService.getIncomes();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  Future<bool> createIncome(Income income) async {
    _setLoading(true);
    _setError(null);

    try {
      final newIncome = await ApiService.createIncome(income);
      _incomes.insert(0, newIncome);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateIncome(String id, Income income) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedIncome = await ApiService.updateIncome(id, income);
      final index = _incomes.indexWhere((i) => i.id == id);
      if (index != -1) {
        _incomes[index] = updatedIncome;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteIncome(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      await ApiService.deleteIncome(id);
      _incomes.removeWhere((i) => i.id == id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Savings Goals methods
  Future<void> loadSavingsGoals() async {
    _setLoading(true);
    _setError(null);

    try {
      _savingsGoals = await ApiService.getSavingsGoals();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  Future<bool> createSavingsGoal(SavingsGoal goal) async {
    _setLoading(true);
    _setError(null);

    try {
      final newGoal = await ApiService.createSavingsGoal(goal);
      _savingsGoals.insert(0, newGoal);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateSavingsGoal(String id, SavingsGoal goal) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedGoal = await ApiService.updateSavingsGoal(id, goal);
      final index = _savingsGoals.indexWhere((g) => g.id == id);
      if (index != -1) {
        _savingsGoals[index] = updatedGoal;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> addToSavingsGoal(String id, double amount) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedGoal = await ApiService.addToSavingsGoal(id, amount);
      final index = _savingsGoals.indexWhere((g) => g.id == id);
      if (index != -1) {
        _savingsGoals[index] = updatedGoal;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteSavingsGoal(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      await ApiService.deleteSavingsGoal(id);
      _savingsGoals.removeWhere((g) => g.id == id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Dashboard and Analytics methods
  Future<void> loadDashboardData() async {
    _setLoading(true);
    _setError(null);

    try {
      _dashboardData = await ApiService.getDashboardData();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  Future<void> loadPredictionData() async {
    _setLoading(true);
    _setError(null);

    try {
      _predictionData = await ApiService.getPrediction();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  Future<void> loadCategoryData({int months = 3}) async {
    _setLoading(true);
    _setError(null);

    try {
      _categoryData = await ApiService.getCategoryAnalytics(months: months);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  // Load all data
  Future<void> loadAllData() async {
    await Future.wait([
      loadExpenses(),
      loadIncomes(),
      loadSavingsGoals(),
      loadDashboardData(),
    ]);
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadAllData();
  }
}
