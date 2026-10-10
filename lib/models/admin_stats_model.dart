import 'package:json_annotation/json_annotation.dart';

part 'admin_stats_model.g.dart';

@JsonSerializable()
class AdminStatsModel {
  final UserStats users;
  final ContentStats content;
  final SessionStats sessions;
  final DateTime timestamp;

  AdminStatsModel({
    required this.users,
    required this.content,
    required this.sessions,
    required this.timestamp,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) =>
      _$AdminStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdminStatsModelToJson(this);
}

@JsonSerializable()
class UserStats {
  final int total;
  final int active;
  final int suspended;
  final int guests;

  UserStats({
    required this.total,
    required this.active,
    required this.suspended,
    required this.guests,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatsToJson(this);
}

@JsonSerializable()
class ContentStats {
  final int total;
  final int published;
  final int pending;
  final int archived;

  ContentStats({
    required this.total,
    required this.published,
    required this.pending,
    required this.archived,
  });

  factory ContentStats.fromJson(Map<String, dynamic> json) =>
      _$ContentStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ContentStatsToJson(this);
}

@JsonSerializable()
class SessionStats {
  final int total;
  final int active;

  SessionStats({
    required this.total,
    required this.active,
  });

  factory SessionStats.fromJson(Map<String, dynamic> json) =>
      _$SessionStatsFromJson(json);

  Map<String, dynamic> toJson() => _$SessionStatsToJson(this);
}
