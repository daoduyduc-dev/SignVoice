import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

/// Category status
enum CategoryStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('ARCHIVED')
  archived,
}

/// Category model
@JsonSerializable()
class CategoryModel {
  @JsonKey(name: '_id')
  final String id;
  
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  
  final int sortOrder;
  final String? parentId;
  
  final CategoryStatus status;
  final int wordCount;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    required this.sortOrder,
    this.parentId,
    required this.status,
    required this.wordCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  /// Check if category is active
  bool get isActive => status == CategoryStatus.active;

  /// Copy with method
  CategoryModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? icon,
    int? sortOrder,
    String? parentId,
    CategoryStatus? status,
    int? wordCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      parentId: parentId ?? this.parentId,
      status: status ?? this.status,
      wordCount: wordCount ?? this.wordCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
