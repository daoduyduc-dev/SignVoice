// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminStatsModel _$AdminStatsModelFromJson(Map<String, dynamic> json) =>
    AdminStatsModel(
      users: UserStats.fromJson(json['users'] as Map<String, dynamic>),
      content: ContentStats.fromJson(json['content'] as Map<String, dynamic>),
      sessions: SessionStats.fromJson(json['sessions'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$AdminStatsModelToJson(AdminStatsModel instance) =>
    <String, dynamic>{
      'users': instance.users,
      'content': instance.content,
      'sessions': instance.sessions,
      'timestamp': instance.timestamp.toIso8601String(),
    };

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
  total: (json['total'] as num).toInt(),
  active: (json['active'] as num).toInt(),
  suspended: (json['suspended'] as num).toInt(),
  guests: (json['guests'] as num).toInt(),
);

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
  'total': instance.total,
  'active': instance.active,
  'suspended': instance.suspended,
  'guests': instance.guests,
};

ContentStats _$ContentStatsFromJson(Map<String, dynamic> json) => ContentStats(
  total: (json['total'] as num).toInt(),
  published: (json['published'] as num).toInt(),
  pending: (json['pending'] as num).toInt(),
  archived: (json['archived'] as num).toInt(),
);

Map<String, dynamic> _$ContentStatsToJson(ContentStats instance) =>
    <String, dynamic>{
      'total': instance.total,
      'published': instance.published,
      'pending': instance.pending,
      'archived': instance.archived,
    };

SessionStats _$SessionStatsFromJson(Map<String, dynamic> json) => SessionStats(
  total: (json['total'] as num).toInt(),
  active: (json['active'] as num).toInt(),
);

Map<String, dynamic> _$SessionStatsToJson(SessionStats instance) =>
    <String, dynamic>{'total': instance.total, 'active': instance.active};
