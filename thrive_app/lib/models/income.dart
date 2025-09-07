import 'package:json_annotation/json_annotation.dart';

part 'income.g.dart';

@JsonSerializable()
class Income {
  @JsonKey(name: '_id')
  final String? id;
  final String userId;
  final double amount;
  final String source;
  final DateTime date;

  Income({
    this.id,
    required this.userId,
    required this.amount,
    required this.source,
    required this.date,
  });

  factory Income.fromJson(Map<String, dynamic> json) => _$IncomeFromJson(json);
  Map<String, dynamic> toJson() => _$IncomeToJson(this);

  Income copyWith({
    String? id,
    String? userId,
    double? amount,
    String? source,
    DateTime? date,
  }) {
    return Income(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      date: date ?? this.date,
    );
  }
}
