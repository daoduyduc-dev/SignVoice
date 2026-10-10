import 'package:json_annotation/json_annotation.dart';

part 'session_model.g.dart';

@JsonSerializable()
class SessionModel {
  final String sessionId;
  final String userId;
  final String device;
  final String ip;
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isCurrent;

  SessionModel({
    required this.sessionId,
    required this.userId,
    required this.device,
    required this.ip,
    required this.createdAt,
    required this.lastActive,
    this.isCurrent = false,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionModelToJson(this);
}
