import 'package:freezed_annotation/freezed_annotation.dart';

part 'month_goal.freezed.dart';
part 'month_goal.g.dart';

@freezed
abstract class MonthGoal with _$MonthGoal {
  const factory MonthGoal({
    required String id,
    required double goalDistance,
    required int year,
    required int month,
    DateTime? createdAt,
  }) = _MonthGoal;

  factory MonthGoal.fromJson(Map<String, dynamic> json) =>
      _$MonthGoalFromJson(json);
}