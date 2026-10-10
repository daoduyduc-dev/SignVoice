import 'package:json_annotation/json_annotation.dart';
import 'dictionary_entry_model.dart';

part 'favorite_model.g.dart';

@JsonSerializable()
class FavoriteModel {
  final String id;
  final String userId;
  final String entryId;
  final DictionaryEntryModel? entry;
  final DateTime createdAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.entryId,
    this.entry,
    required this.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) =>
      _$FavoriteModelFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteModelToJson(this);
}
