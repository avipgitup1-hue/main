// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Income _$IncomeFromJson(Map<String, dynamic> json) => Income(
  id: json['_id'] as String?,
  userId: Income._userIdFromJson(json['userId']),
  amount: (json['amount'] as num).toDouble(),
  source: json['source'] as String,
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$IncomeToJson(Income instance) => <String, dynamic>{
  '_id': instance.id,
  'userId': Income._userIdToJson(instance.userId),
  'amount': instance.amount,
  'source': instance.source,
  'date': instance.date.toIso8601String(),
};
