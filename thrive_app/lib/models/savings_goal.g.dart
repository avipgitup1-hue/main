// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavingsGoal _$SavingsGoalFromJson(Map<String, dynamic> json) => SavingsGoal(
  id: json['_id'] as String?,
  userId: SavingsGoal._userIdFromJson(json['userId']),
  title: json['title'] as String,
  targetAmount: (json['targetAmount'] as num).toDouble(),
  currentAmount: (json['currentAmount'] as num).toDouble(),
  deadline: json['deadline'] == null
      ? null
      : DateTime.parse(json['deadline'] as String),
);

Map<String, dynamic> _$SavingsGoalToJson(SavingsGoal instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userId': SavingsGoal._userIdToJson(instance.userId),
      'title': instance.title,
      'targetAmount': instance.targetAmount,
      'currentAmount': instance.currentAmount,
      'deadline': instance.deadline?.toIso8601String(),
    };
