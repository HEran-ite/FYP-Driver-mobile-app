library;

import '../../domain/entities/post.dart';

class PostCommentModel {
  const PostCommentModel({
    required this.id,
    required this.postId,
    required this.content,
    required this.author,
    required this.isMine,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String postId;
  final String content;
  final PostAuthor author;
  final bool isMine;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PostCommentModel.fromJson(Map<String, dynamic>? json) {
    final m = json ?? const <String, dynamic>{};
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    bool parseBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = v?.toString().toLowerCase().trim();
      return s == 'true' || s == '1';
    }

    final authorMap = (m['author'] is Map<String, dynamic>)
        ? (m['author'] as Map<String, dynamic>)
        : const <String, dynamic>{};

    return PostCommentModel(
      id: m['id']?.toString() ?? '',
      postId: m['postId']?.toString() ?? '',
      content: m['content']?.toString() ?? '',
      author: PostAuthor(
        id: authorMap['id']?.toString() ?? '',
        firstName: authorMap['firstName']?.toString() ?? '',
        lastName: authorMap['lastName']?.toString() ?? '',
      ),
      isMine: parseBool(m['isMine']),
      createdAt: parseDate(m['createdAt']),
      updatedAt: parseDate(m['updatedAt']),
    );
  }

  PostComment toEntity() => PostComment(
    id: id,
    postId: postId,
    content: content,
    author: author,
    isMine: isMine,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
