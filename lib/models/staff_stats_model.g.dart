// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffStatsModel _$StaffStatsModelFromJson(Map<String, dynamic> json) =>
    StaffStatsModel(
      content: ContentStaffStats.fromJson(
        json['content'] as Map<String, dynamic>,
      ),
      users: UserStaffStats.fromJson(json['users'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StaffStatsModelToJson(StaffStatsModel instance) =>
    <String, dynamic>{'content': instance.content, 'users': instance.users};

ContentStaffStats _$ContentStaffStatsFromJson(Map<String, dynamic> json) =>
    ContentStaffStats(
      pending: (json['pending'] as num).toInt(),
      published: (json['published'] as num).toInt(),
    );

Map<String, dynamic> _$ContentStaffStatsToJson(ContentStaffStats instance) =>
    <String, dynamic>{
      'pending': instance.pending,
      'published': instance.published,
    };

UserStaffStats _$UserStaffStatsFromJson(Map<String, dynamic> json) =>
    UserStaffStats(
      total: (json['total'] as num).toInt(),
      recentWeek: (json['recentWeek'] as num).toInt(),
    );

Map<String, dynamic> _$UserStaffStatsToJson(UserStaffStats instance) =>
    <String, dynamic>{
      'total': instance.total,
      'recentWeek': instance.recentWeek,
    };
