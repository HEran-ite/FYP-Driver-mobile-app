library;

import 'package:equatable/equatable.dart';

abstract class CommunityEvent extends Equatable {
  const CommunityEvent();
  @override
  List<Object?> get props => [];
}

class CommunityLoadRequested extends CommunityEvent {
  const CommunityLoadRequested();
}

class CommunityRefreshRequested extends CommunityEvent {
  const CommunityRefreshRequested();
}

class CommunitySearchRequested extends CommunityEvent {
  const CommunitySearchRequested(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class CommunityCreatePostRequested extends CommunityEvent {
  const CommunityCreatePostRequested({
    required this.title,
    required this.content,
    this.imageUrl,
    this.imageFilePath,
  });

  final String title;
  final String content;
  final String? imageUrl;
  final String? imageFilePath;

  @override
  List<Object?> get props => [title, content, imageUrl, imageFilePath];
}

class CommunityDeletePostRequested extends CommunityEvent {
  const CommunityDeletePostRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class CommunityEditPostRequested extends CommunityEvent {
  const CommunityEditPostRequested({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String content;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, title, content, imageUrl];
}

class CommunityToggleLikeRequested extends CommunityEvent {
  const CommunityToggleLikeRequested(this.postId);
  final String postId;

  @override
  List<Object?> get props => [postId];
}

class CommunityToggleBookmarkRequested extends CommunityEvent {
  const CommunityToggleBookmarkRequested(this.postId);
  final String postId;

  @override
  List<Object?> get props => [postId];
}

class CommunityReportPostRequested extends CommunityEvent {
  const CommunityReportPostRequested({
    required this.postId,
    required this.reason,
    this.details,
  });

  final String postId;
  final String reason;
  final String? details;

  @override
  List<Object?> get props => [postId, reason, details];
}

class CommunityCommentsLoadRequested extends CommunityEvent {
  const CommunityCommentsLoadRequested(this.postId);
  final String postId;

  @override
  List<Object?> get props => [postId];
}

class CommunityCreateCommentRequested extends CommunityEvent {
  const CommunityCreateCommentRequested({
    required this.postId,
    required this.content,
  });

  final String postId;
  final String content;

  @override
  List<Object?> get props => [postId, content];
}

class CommunityDeleteCommentRequested extends CommunityEvent {
  const CommunityDeleteCommentRequested({
    required this.postId,
    required this.commentId,
  });

  final String postId;
  final String commentId;

  @override
  List<Object?> get props => [postId, commentId];
}
