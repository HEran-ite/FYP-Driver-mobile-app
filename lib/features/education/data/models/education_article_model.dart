library;

import '../../domain/entities/education_article.dart';

class EducationArticleModel {
  const EducationArticleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final EducationCategory category;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory EducationArticleModel.fromJson(Map<String, dynamic> json) {
    return EducationArticleModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: _parseCategory(json['category']?.toString()),
      imageUrl: json['image']?.toString(),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static EducationCategory _parseCategory(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'SAFETY':
        return EducationCategory.safety;
      case 'MAINTENANCE':
        return EducationCategory.maintenance;
      case 'REPAIRS':
        return EducationCategory.repairs;
      case 'TIPS':
        return EducationCategory.tips;
      default:
        return EducationCategory.all;
    }
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  EducationArticle toEntity() => EducationArticle(
        id: id,
        title: title,
        description: description,
        category: category,
        imageUrl: imageUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
