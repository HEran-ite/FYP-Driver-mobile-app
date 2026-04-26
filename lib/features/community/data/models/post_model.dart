library;

import 'dart:convert';

import '../../domain/entities/post.dart';

class PostModel {
  const PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.stats,
    required this.isLikedByMe,
    required this.isBookmarkedByMe,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final PostAuthor author;
  final PostStats stats;
  final bool isLikedByMe;
  final bool isBookmarkedByMe;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PostModel.fromJson(Map<String, dynamic>? json) {
    final m = json ?? const <String, dynamic>{};
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    int parseInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    bool parseBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = v?.toString().toLowerCase().trim();
      if (s == 'true' || s == '1') return true;
      return false;
    }

    final authorMap = (m['author'] is Map<String, dynamic>)
        ? (m['author'] as Map<String, dynamic>)
        : <String, dynamic>{'id': m['authorId']?.toString() ?? ''};

    final statsMap = (m['stats'] is Map<String, dynamic>)
        ? (m['stats'] as Map<String, dynamic>)
        : const <String, dynamic>{};

    String? parseImageField(Map<String, dynamic> map) {
      final merged = map['images'];
      if (merged is List) {
        final urls = merged
            .map((e) => e?.toString().trim() ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
        if (urls.isNotEmpty) return jsonEncode(urls);
      }

      final single = map['imageUrl'];
      if (single != null && single.toString().trim().isNotEmpty) {
        return single.toString().trim();
      }
      final multi = map['imageUrls'];
      if (multi is List) {
        String normalize(dynamic e) {
          if (e == null) return '';
          if (e is String) return e.trim();
          if (e is Map) {
            final mm = Map<dynamic, dynamic>.from(e);
            final v = mm['url'] ?? mm['imageUrl'] ?? mm['path'];
            return v?.toString().trim() ?? '';
          }
          return e.toString().trim();
        }

        final urls = multi.map(normalize).where((e) => e.isNotEmpty).toList();
        if (urls.isNotEmpty) return jsonEncode(urls);
      } else if (multi is String && multi.trim().isNotEmpty) {
        return multi.trim();
      }
      return null;
    }

    return PostModel(
      id: m['id']?.toString() ?? '',
      title: m['title']?.toString() ?? '',
      content: m['content']?.toString() ?? '',
      author: PostAuthor(
        id: authorMap['id']?.toString() ?? '',
        firstName: authorMap['firstName']?.toString() ?? '',
        lastName: authorMap['lastName']?.toString() ?? '',
      ),
      stats: PostStats(
        likeCount: parseInt(statsMap['likeCount']),
        commentCount: parseInt(statsMap['commentCount']),
        bookmarkCount: parseInt(statsMap['bookmarkCount']),
      ),
      isLikedByMe: parseBool(m['isLikedByMe']),
      isBookmarkedByMe: parseBool(m['isBookmarkedByMe']),
      imageUrl: parseImageField(m),
      createdAt: parseDate(m['createdAt']),
      updatedAt: parseDate(m['updatedAt']),
    );
  }

  Post toEntity() => Post(
    id: id,
    title: title.isEmpty ? _deriveTitle(content) : title,
    content: content,
    author: author,
    stats: stats,
    isLikedByMe: isLikedByMe,
    isBookmarkedByMe: isBookmarkedByMe,
    imageUrl: imageUrl,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static String _deriveTitle(String content) {
    final c = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (c.isEmpty) return 'Post';
    return c.length <= 50 ? c : '${c.substring(0, 50)}...';
  }
}
