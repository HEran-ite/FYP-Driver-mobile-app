library;

import '../../domain/entities/education_article.dart';
import '../../../../core/constants/api_endpoints.dart';

class EducationArticleModel {
  const EducationArticleModel({
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

  factory EducationArticleModel.fromJson(Map<String, dynamic> json) {
    return EducationArticleModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: _parseCategory(json['category']?.toString()),
      imageUrl: _normalizeUrl(json['image']?.toString()),
      manualUrl: _extractManualUrl(json),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static String? _extractManualUrl(Map<String, dynamic> json) {
    final candidates = [
      json['pdf'],
      json['manualUrl'],
      json['manual_url'],
      json['pdfUrl'],
      json['pdf_url'],
      json['fileUrl'],
      json['file_url'],
      json['attachmentUrl'],
      json['attachment_url'],
      json['documentUrl'],
      json['document_url'],
    ];
    for (final raw in candidates) {
      final value = raw?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return _normalizeUrl(value);
      }
    }
    return null;
  }

  static String? _normalizeUrl(String? raw) {
    final value = raw?.trim().replaceAll('\\', '/');
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) {
      // Backend can return localhost URLs, which break on Android emulator/device.
      final host = uri.host.toLowerCase();
      if (host == 'localhost' || host == '127.0.0.1') {
        final base = Uri.parse(ApiEndpoints.baseUrl);
        return uri.replace(
          scheme: base.scheme,
          host: base.host,
          port: base.hasPort ? base.port : uri.port,
        ).toString();
      }
      return value;
    }
    final base = ApiEndpoints.baseUrl;
    // Backend often stores manual PDFs as bare filenames in /uploads.
    final looksLikeBareFilename =
        !value.contains('/') && value.toLowerCase().endsWith('.pdf');
    if (looksLikeBareFilename) return '$base/uploads/$value';
    if (value.startsWith('/')) return '$base$value';
    return '$base/$value';
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
      case 'MANUALS':
        return EducationCategory.manuals;
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
        manualUrl: manualUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
