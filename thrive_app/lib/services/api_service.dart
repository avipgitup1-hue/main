import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/savings_goal.dart';
import '../models/dashboard_data.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const _storage = FlutterSecureStorage();

  // Auth endpoints
  static Future<AuthResponse> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);
      await _storage.write(key: 'auth_token', value: authResponse.token);
      return authResponse;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['msg'] ?? 'Registration failed');
    }
  }

  static Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);
      await _storage.write(key: 'auth_token', value: authResponse.token);
      return authResponse;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['msg'] ?? 'Login failed');
    }
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Expense endpoints
  static Future<List<Expense>> getExpenses() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/expenses'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Expense.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  static Future<Expense> createExpense(Expense expense) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: headers,
      body: jsonEncode(expense.toJson()),
    );

    if (response.statusCode == 201) {
      return Expense.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['msg'] ?? 'Failed to create expense');
    }
  }

  static Future<Expense> updateExpense(String id, Expense expense) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/expenses/$id'),
      headers: headers,
      body: jsonEncode(expense.toJson()),
    );

    if (response.statusCode == 200) {
      return Expense.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['msg'] ?? 'Failed to update expense');
    }
  }

  static Future<void> deleteExpense(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/expenses/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['msg'] ?? 'Failed to delete expense');
    }
  }

  // Income endpoints
  static Future<List<Income>> getIncomes() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/incomes'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Income.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load incomes');
    }
  }

  static Future<Income> createIncome(Income income) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/incomes'),
      headers: headers,
      body: jsonEncode(income.toJson()),
    );

    if (response.statusCode == 201) {
      return Income.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['msg'] ?? 'Failed to create income');
    }
  }

  static Future<Income> updateIncome(String id, Income income) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/incomes/$id'),
      headers: headers,
      body: jsonEncode(income.toJson()),
    );

    if (response.statusCode == 200) {
      return Income.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['msg'] ?? 'Failed to update income');
    }
  }

  static Future<void> deleteIncome(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/incomes/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['msg'] ?? 'Failed to delete income');
    }
  }

  // Savings Goals endpoints
  static Future<List<SavingsGoal>> getSavingsGoals() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/goals'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SavingsGoal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load savings goals');
    }
  }

  static Future<SavingsGoal> createSavingsGoal(SavingsGoal goal) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/goals'),
      headers: headers,
      body: jsonEncode(goal.toJson()),
    );

    if (response.statusCode == 201) {
      return SavingsGoal.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['msg'] ?? 'Failed to create savings goal');
    }
  }

  static Future<SavingsGoal> updateSavingsGoal(String id, SavingsGoal goal) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/goals/$id'),
      headers: headers,
      body: jsonEncode(goal.toJson()),
    );

    if (response.statusCode == 200) {
      return SavingsGoal.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['msg'] ?? 'Failed to update savings goal');
    }
  }

  static Future<SavingsGoal> addToSavingsGoal(String id, double amount) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl/goals/$id/add'),
      headers: headers,
      body: jsonEncode({'amount': amount}),
    );

    if (response.statusCode == 200) {
      return SavingsGoal.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['msg'] ?? 'Failed to add to savings goal');
    }
  }

  static Future<void> deleteSavingsGoal(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/goals/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['msg'] ?? 'Failed to delete savings goal');
    }
  }

  // Analytics endpoints
  static Future<DashboardData> getDashboardData() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/predict/dashboard'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return DashboardData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load dashboard data');
    }
  }

  static Future<PredictionData> getPrediction() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/predict'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return PredictionData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load prediction');
    }
  }

  static Future<List<CategoryData>> getCategoryAnalytics({int months = 3}) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/predict/analytics/categories?months=$months'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CategoryData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load category analytics');
    }
  }
}
