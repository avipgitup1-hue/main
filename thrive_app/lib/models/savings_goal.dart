import 'package:json_annotation/json_annotation.dart';

part 'savings_goal.g.dart';

@JsonSerializable()
class SavingsGoal {
  @JsonKey(name: '_id')
  final String? id;
  @JsonKey(name: 'userId', fromJson: _userIdFromJson, toJson: _userIdToJson)
  final String userId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;

  SavingsGoal({
    this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
  });

  static String _userIdFromJson(dynamic userId) {
    if (userId is String) {
      return userId;
    } else if (userId is Map<String, dynamic>) {
      return userId['_id'] ?? userId['id'] ?? '';
    }
    return '';
  }

  static dynamic _userIdToJson(String userId) => userId;

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => _$SavingsGoalFromJson(json);
  Map<String, dynamic> toJson() => _$SavingsGoalToJson(this);

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;

  SavingsGoal copyWith({
    String? id,
    String? userId,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
    );
  }
}
