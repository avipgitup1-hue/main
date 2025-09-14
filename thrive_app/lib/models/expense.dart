import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

@JsonSerializable()
class Expense {
  @JsonKey(name: '_id')
  final String? id;
  @JsonKey(name: 'userId', fromJson: _userIdFromJson, toJson: _userIdToJson)
  final String userId;
  final double amount;
  final String category;
  final String? description;
  final DateTime date;

  Expense({
    this.id,
    required this.userId,
    required this.amount,
    required this.category,
    this.description,
    required this.date,
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

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

  Expense copyWith({
    String? id,
    String? userId,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}
