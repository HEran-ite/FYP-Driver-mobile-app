library;

import '../../domain/entities/post.dart';

class PostModel {
  const PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    this.imageUrl,
    this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final String authorId;
  final String? imageUrl;
  final DateTime? createdAt;

  factory PostModel.fromJson(Map<String, dynamic>? json) {
    final m = json ?? const <String, dynamic>{};
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    return PostModel(
      id: m['id']?.toString() ?? '',
      title: m['title']?.toString() ?? '',
      content: m['content']?.toString() ?? '',
      authorId: m['authorId']?.toString() ?? '',
      imageUrl: m['imageUrl']?.toString(),
      createdAt: parseDate(m['createdAt']),
    );
  }

  Post toEntity() => Post(
        id: id,
        title: title,
        content: content,
        authorId: authorId,
        imageUrl: imageUrl,
        createdAt: createdAt,
      );
}

