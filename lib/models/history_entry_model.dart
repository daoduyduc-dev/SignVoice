import 'package:json_annotation/json_annotation.dart';
import 'dictionary_entry_model.dart';

part 'history_entry_model.g.dart';

@JsonSerializable()
class HistoryEntryModel {
  final String id;
  final String userId;
  final String entryId;
  final DictionaryEntryModel? entry;
  final DateTime viewedAt;

  HistoryEntryModel({
    required this.id,
    required this.userId,
    required this.entryId,
    this.entry,
    required this.viewedAt,
  });

  factory HistoryEntryModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryEntryModelFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryEntryModelToJson(this);
}
