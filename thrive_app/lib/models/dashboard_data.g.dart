// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardData _$DashboardDataFromJson(Map<String, dynamic> json) =>
    DashboardData(
      currentMonth: MonthlyData.fromJson(
        json['currentMonth'] as Map<String, dynamic>,
      ),
      previousMonth: MonthlyData.fromJson(
        json['previousMonth'] as Map<String, dynamic>,
      ),
      categoryBreakdown: (json['categoryBreakdown'] as List<dynamic>)
          .map((e) => CategoryData.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentTransactions: (json['recentTransactions'] as List<dynamic>)
          .map((e) => TransactionData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardDataToJson(DashboardData instance) =>
    <String, dynamic>{
      'currentMonth': instance.currentMonth,
      'previousMonth': instance.previousMonth,
      'categoryBreakdown': instance.categoryBreakdown,
      'recentTransactions': instance.recentTransactions,
    };

MonthlyData _$MonthlyDataFromJson(Map<String, dynamic> json) => MonthlyData(
  totalExpenses: (json['totalExpenses'] as num).toDouble(),
  totalIncome: (json['totalIncome'] as num).toDouble(),
  savingsGoalProgress: (json['savingsGoalProgress'] as num).toDouble(),
  transactionCount: (json['transactionCount'] as num).toInt(),
);

Map<String, dynamic> _$MonthlyDataToJson(MonthlyData instance) =>
    <String, dynamic>{
      'totalExpenses': instance.totalExpenses,
      'totalIncome': instance.totalIncome,
      'savingsGoalProgress': instance.savingsGoalProgress,
      'transactionCount': instance.transactionCount,
    };

CategoryData _$CategoryDataFromJson(Map<String, dynamic> json) => CategoryData(
  category: json['category'] as String,
  amount: (json['amount'] as num).toDouble(),
  count: (json['count'] as num).toInt(),
  percentage: (json['percentage'] as num).toDouble(),
);

Map<String, dynamic> _$CategoryDataToJson(CategoryData instance) =>
    <String, dynamic>{
      'category': instance.category,
      'amount': instance.amount,
      'count': instance.count,
      'percentage': instance.percentage,
    };

TransactionData _$TransactionDataFromJson(Map<String, dynamic> json) =>
    TransactionData(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String?,
    );

Map<String, dynamic> _$TransactionDataToJson(TransactionData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'description': instance.description,
      'date': instance.date.toIso8601String(),
      'category': instance.category,
    };

PredictionData _$PredictionDataFromJson(Map<String, dynamic> json) =>
    PredictionData(
      predictedSpending: (json['predictedSpending'] as num).toDouble(),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      month: json['month'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PredictionDataToJson(PredictionData instance) =>
    <String, dynamic>{
      'predictedSpending': instance.predictedSpending,
      'confidenceScore': instance.confidenceScore,
      'month': instance.month,
      'recommendations': instance.recommendations,
    };
