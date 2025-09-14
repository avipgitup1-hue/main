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

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('API Service: Attempting login for $email');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('API Service: Login response status: ${response.statusCode}');
      print('API Service: Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'auth_token', value: data['token']);
        print('Login successful: Token stored');
        return {
          'success': true,
          'user': data['user'],
          'token': data['token']
        };
      } else {
        final error = jsonDecode(response.body);
        print('API Service: Login failed with error: ${error['msg']}');
        return {
          'success': false,
          'message': error['msg'] ?? 'Login failed'
        };
      }
    } catch (e) {
      print('API Service: Login exception: $e');
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: 'auth_token');
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['x-auth-token'] = token;
      print('API Service: Using token for request: ${token.substring(0, 10)}...');
    } else {
      print('API Service: No token available for request');
    }
    
    return headers;
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
    final payload = expense.toJson();
    // Remove fields that should not be sent to backend for new records
    payload.remove('id');
    payload.remove('_id');
    payload.remove('userId');
    
    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: headers,
      body: jsonEncode(payload),
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
    final payload = income.toJson();
    // Remove fields that should not be sent to backend for new records
    payload.remove('id');
    payload.remove('_id');
    payload.remove('userId');
    
    final response = await http.post(
      Uri.parse('$baseUrl/incomes'),
      headers: headers,
      body: jsonEncode(payload),
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
    final payload = goal.toJson();
    // Remove fields that should not be sent to backend for new records
    payload.remove('id');
    payload.remove('_id');
    payload.remove('userId');
    
    final response = await http.post(
      Uri.parse('$baseUrl/goals'),
      headers: headers,
      body: jsonEncode(payload),
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

  // Generic HTTP methods for admin functionality
  static Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required. Please login.');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['msg'] ?? 'Request failed');
      } catch (e) {
        throw Exception('Request failed with status ${response.statusCode}');
      }
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required. Please login.');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['msg'] ?? 'Request failed');
      } catch (e) {
        throw Exception('Request failed with status ${response.statusCode}');
      }
    }
  }

  static Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required. Please login.');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['msg'] ?? 'Request failed');
      } catch (e) {
        throw Exception('Request failed with status ${response.statusCode}');
      }
    }
  }

  static Future<void> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required. Please login.');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. Admin privileges required.');
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['msg'] ?? 'Request failed');
      } catch (e) {
        throw Exception('Request failed with status ${response.statusCode}');
      }
    }
  }
}
