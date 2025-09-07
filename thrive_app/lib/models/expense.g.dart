// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  id: json['id'] as String?,
  userId: json['userId'] as String,
  amount: (json['amount'] as num).toDouble(),
  category: json['category'] as String,
  description: json['description'] as String?,
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'amount': instance.amount,
  'category': instance.category,
  'description': instance.description,
  'date': instance.date.toIso8601String(),
};
