// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  id: json['_id'] as String?,
  userId: Expense._userIdFromJson(json['userId']),
  amount: (json['amount'] as num).toDouble(),
  category: json['category'] as String,
  description: json['description'] as String?,
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  '_id': instance.id,
  'userId': Expense._userIdToJson(instance.userId),
  'amount': instance.amount,
  'category': instance.category,
  'description': instance.description,
  'date': instance.date.toIso8601String(),
};
