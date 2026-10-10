// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionModel _$SessionModelFromJson(Map<String, dynamic> json) => SessionModel(
  sessionId: json['sessionId'] as String,
  userId: json['userId'] as String,
  device: json['device'] as String,
  ip: json['ip'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastActive: DateTime.parse(json['lastActive'] as String),
  isCurrent: json['isCurrent'] as bool? ?? false,
);

Map<String, dynamic> _$SessionModelToJson(SessionModel instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'userId': instance.userId,
      'device': instance.device,
      'ip': instance.ip,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastActive': instance.lastActive.toIso8601String(),
      'isCurrent': instance.isCurrent,
    };
