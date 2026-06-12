// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MonthGoal _$MonthGoalFromJson(Map<String, dynamic> json) => _MonthGoal(
  id: json['id'] as String,
  goalDistance: (json['goalDistance'] as num).toDouble(),
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num).toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MonthGoalToJson(_MonthGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goalDistance': instance.goalDistance,
      'year': instance.year,
      'month': instance.month,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
