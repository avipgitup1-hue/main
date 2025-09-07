import 'package:json_annotation/json_annotation.dart';

part 'dashboard_data.g.dart';

@JsonSerializable()
class DashboardData {
  final MonthlyData currentMonth;
  final MonthlyData previousMonth;
  final List<CategoryData> categoryBreakdown;
  final List<TransactionData> recentTransactions;

  DashboardData({
    required this.currentMonth,
    required this.previousMonth,
    required this.categoryBreakdown,
    required this.recentTransactions,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => _$DashboardDataFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardDataToJson(this);
}

@JsonSerializable()
class MonthlyData {
  final double totalExpenses;
  final double totalIncome;
  final double savingsGoalProgress;
  final int transactionCount;

  MonthlyData({
    required this.totalExpenses,
    required this.totalIncome,
    required this.savingsGoalProgress,
    required this.transactionCount,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) => _$MonthlyDataFromJson(json);
  Map<String, dynamic> toJson() => _$MonthlyDataToJson(this);
}

@JsonSerializable()
class CategoryData {
  final String category;
  final double amount;
  final int count;
  final double percentage;

  CategoryData({
    required this.category,
    required this.amount,
    required this.count,
    required this.percentage,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) => _$CategoryDataFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryDataToJson(this);
}

@JsonSerializable()
class TransactionData {
  final String id;
  final String type;
  final double amount;
  final String description;
  final DateTime date;
  final String? category;

  TransactionData({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    this.category,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) => _$TransactionDataFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionDataToJson(this);
}

@JsonSerializable()
class PredictionData {
  final double predictedSpending;
  final double confidenceScore;
  final String month;
  final List<String> recommendations;

  PredictionData({
    required this.predictedSpending,
    required this.confidenceScore,
    required this.month,
    required this.recommendations,
  });

  factory PredictionData.fromJson(Map<String, dynamic> json) => _$PredictionDataFromJson(json);
  Map<String, dynamic> toJson() => _$PredictionDataToJson(this);
}
