library;

import 'dart:convert';

import 'package:equatable/equatable.dart';

class PostAuthor extends Equatable {
  const PostAuthor({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  final String id;
  final String firstName;
  final String lastName;

  String get displayName {
    final full = '$firstName $lastName'.trim();
    if (full.isNotEmpty) return full;
    if (id.trim().isEmpty) return 'Driver';
    final safe = id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final tail = safe.length <= 4 ? safe : safe.substring(safe.length - 4);
    return 'Driver $tail';
  }

  String get initials {
    final source = displayName.trim();
    if (source.isEmpty) return 'D';
    final parts = source
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.length == 1) {
      final s = parts.first;
      return s.substring(0, s.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  List<Object?> get props => [id, firstName, lastName];
}

class PostStats extends Equatable {
  const PostStats({
    required this.likeCount,
    required this.commentCount,
    required this.bookmarkCount,
  });

  final int likeCount;
  final int commentCount;
  final int bookmarkCount;

  @override
  List<Object?> get props => [likeCount, commentCount, bookmarkCount];
}

class Post extends Equatable {
  const Post({
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

  List<String> get imageUrls {
    final raw = imageUrl?.trim();
    if (raw == null || raw.isEmpty) return const <String>[];
    if (raw.startsWith('[')) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .map((e) => e?.toString().trim() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } catch (_) {
        return <String>[raw];
      }
    }
    return <String>[raw];
  }

  Post copyWith({
    String? id,
    String? title,
    String? content,
    PostAuthor? author,
    PostStats? stats,
    bool? isLikedByMe,
    bool? isBookmarkedByMe,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      stats: stats ?? this.stats,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isBookmarkedByMe: isBookmarkedByMe ?? this.isBookmarkedByMe,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    author,
    stats,
    isLikedByMe,
    isBookmarkedByMe,
    imageUrl,
    createdAt,
    updatedAt,
  ];
}

class PostComment extends Equatable {
  const PostComment({
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

  @override
  List<Object?> get props => [
    id,
    postId,
    content,
    author,
    isMine,
    createdAt,
    updatedAt,
  ];
}
