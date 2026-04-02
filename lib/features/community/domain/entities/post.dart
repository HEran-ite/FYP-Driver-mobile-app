library;

import 'package:equatable/equatable.dart';

class Post extends Equatable {
  const Post({
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

  @override
  List<Object?> get props => [id, title, content, authorId, imageUrl, createdAt];
}

