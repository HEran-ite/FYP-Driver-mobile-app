library;

import 'package:equatable/equatable.dart';

/// Aligns with driver-garage-backend `EducationCategory`.
enum EducationCategory {
  all,
  safety,
  maintenance,
  repairs,
  tips,
  manuals,
}

extension EducationCategoryDisplay on EducationCategory {
  String get displayLabel {
    switch (this) {
      case EducationCategory.safety:
        return 'Safety';
      case EducationCategory.maintenance:
        return 'Maintenance';
      case EducationCategory.repairs:
        return 'Repair';
      case EducationCategory.tips:
        return 'Tips';
      case EducationCategory.all:
        return 'General';
      case EducationCategory.manuals:
        return 'Manuals';
    }
  }
}

class EducationArticle extends Equatable {
  const EducationArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.imageUrl,
    this.manualUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final EducationCategory category;
  final String? imageUrl;
  final String? manualUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get categoryLabel => category.displayLabel;

  /// Subheading for cards (API has no separate field).
  String get topicTag {
    switch (category) {
      case EducationCategory.safety:
        return 'Safety tips';
      case EducationCategory.maintenance:
        return 'Maintenance basics';
      case EducationCategory.repairs:
        return 'Repair guides';
      case EducationCategory.tips:
        return 'Tips & tricks';
      case EducationCategory.all:
        return 'Guide';
      case EducationCategory.manuals:
        return 'Manual';
    }
  }

  /// UI-only: backend has no difficulty; used for badges.
  String get difficultyLabel =>
      category == EducationCategory.repairs ? 'Intermediate' : 'Beginner';

  /// Rough read time from body length (API has no dedicated field).
  int get estimatedReadMinutes {
    final n = (description.length / 650).ceil();
    return n.clamp(1, 45);
  }

  @override
  List<Object?> get props =>
      [id, title, description, category, imageUrl, manualUrl, createdAt, updatedAt];
}
