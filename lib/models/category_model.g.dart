// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      sortOrder: (json['sortOrder'] as num).toInt(),
      parentId: json['parentId'] as String?,
      status: $enumDecode(_$CategoryStatusEnumMap, json['status']),
      wordCount: (json['wordCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'icon': instance.icon,
      'sortOrder': instance.sortOrder,
      'parentId': instance.parentId,
      'status': _$CategoryStatusEnumMap[instance.status]!,
      'wordCount': instance.wordCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$CategoryStatusEnumMap = {
  CategoryStatus.active: 'ACTIVE',
  CategoryStatus.archived: 'ARCHIVED',
};
