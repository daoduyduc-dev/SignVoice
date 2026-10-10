import 'package:json_annotation/json_annotation.dart';

part 'staff_stats_model.g.dart';

@JsonSerializable()
class StaffStatsModel {
  final ContentStaffStats content;
  final UserStaffStats users;

  StaffStatsModel({
    required this.content,
    required this.users,
  });

  factory StaffStatsModel.fromJson(Map<String, dynamic> json) =>
      _$StaffStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$StaffStatsModelToJson(this);
}

@JsonSerializable()
class ContentStaffStats {
  final int pending;
  final int published;

  ContentStaffStats({
    required this.pending,
    required this.published,
  });

  factory ContentStaffStats.fromJson(Map<String, dynamic> json) =>
      _$ContentStaffStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ContentStaffStatsToJson(this);
}

@JsonSerializable()
class UserStaffStats {
  final int total;
  final int recentWeek;

  UserStaffStats({
    required this.total,
    required this.recentWeek,
  });

  factory UserStaffStats.fromJson(Map<String, dynamic> json) =>
      _$UserStaffStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UserStaffStatsToJson(this);
}
