// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RelatedWord _$RelatedWordFromJson(Map<String, dynamic> json) => RelatedWord(
  entryId: json['entryId'] as String,
  relationshipType: $enumDecode(
    _$RelationshipTypeEnumMap,
    json['relationshipType'],
  ),
);

Map<String, dynamic> _$RelatedWordToJson(RelatedWord instance) =>
    <String, dynamic>{
      'entryId': instance.entryId,
      'relationshipType': _$RelationshipTypeEnumMap[instance.relationshipType]!,
    };

const _$RelationshipTypeEnumMap = {
  RelationshipType.synonym: 'SYNONYM',
  RelationshipType.antonym: 'ANTONYM',
  RelationshipType.related: 'RELATED',
  RelationshipType.seeAlso: 'SEE_ALSO',
};

DictionaryEntryModel _$DictionaryEntryModelFromJson(
  Map<String, dynamic> json,
) => DictionaryEntryModel(
  id: json['_id'] as String,
  word: json['word'] as String,
  definition: json['definition'] as String,
  videoUrl: json['videoUrl'] as String,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  imageUrls: (json['imageUrls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  categoryId: json['categoryId'] as String,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  difficulty: $enumDecodeNullable(_$DifficultyLevelEnumMap, json['difficulty']),
  usageExample: json['usageExample'] as String?,
  notes: json['notes'] as String?,
  relatedWords: (json['relatedWords'] as List<dynamic>?)
      ?.map((e) => RelatedWord.fromJson(e as Map<String, dynamic>))
      .toList(),
  status: $enumDecode(_$EntryStatusEnumMap, json['status']),
  rejectionReason: json['rejectionReason'] as String?,
  viewCount: (json['viewCount'] as num).toInt(),
  favoriteCount: (json['favoriteCount'] as num).toInt(),
  createdBy: json['createdBy'] as String,
  lastModifiedBy: json['lastModifiedBy'] as String?,
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$DictionaryEntryModelToJson(
  DictionaryEntryModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'word': instance.word,
  'definition': instance.definition,
  'videoUrl': instance.videoUrl,
  'thumbnailUrl': instance.thumbnailUrl,
  'imageUrls': instance.imageUrls,
  'categoryId': instance.categoryId,
  'tags': instance.tags,
  'difficulty': _$DifficultyLevelEnumMap[instance.difficulty],
  'usageExample': instance.usageExample,
  'notes': instance.notes,
  'relatedWords': instance.relatedWords,
  'status': _$EntryStatusEnumMap[instance.status]!,
  'rejectionReason': instance.rejectionReason,
  'viewCount': instance.viewCount,
  'favoriteCount': instance.favoriteCount,
  'createdBy': instance.createdBy,
  'lastModifiedBy': instance.lastModifiedBy,
  'publishedAt': instance.publishedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$DifficultyLevelEnumMap = {
  DifficultyLevel.beginner: 'BEGINNER',
  DifficultyLevel.intermediate: 'INTERMEDIATE',
  DifficultyLevel.advanced: 'ADVANCED',
};

const _$EntryStatusEnumMap = {
  EntryStatus.draft: 'DRAFT',
  EntryStatus.published: 'PUBLISHED',
  EntryStatus.archived: 'ARCHIVED',
};
