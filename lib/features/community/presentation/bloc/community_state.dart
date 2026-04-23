library;

import 'package:equatable/equatable.dart';

import '../../domain/entities/post.dart';

abstract class CommunityState extends Equatable {
  const CommunityState();
  @override
  List<Object?> get props => [];
}

class CommunityInitial extends CommunityState {
  const CommunityInitial();
}

class CommunityLoading extends CommunityState {
  const CommunityLoading();
}

class CommunityLoaded extends CommunityState {
  const CommunityLoaded({
    required this.posts,
    required this.bookmarkedPosts,
    this.commentsByPostId = const {},
    this.commentsLoadingPostIds = const <String>{},
  });

  final List<Post> posts;
  final List<Post> bookmarkedPosts;
  final Map<String, List<PostComment>> commentsByPostId;
  final Set<String> commentsLoadingPostIds;

  CommunityLoaded copyWith({
    List<Post>? posts,
    List<Post>? bookmarkedPosts,
    Map<String, List<PostComment>>? commentsByPostId,
    Set<String>? commentsLoadingPostIds,
  }) {
    return CommunityLoaded(
      posts: posts ?? this.posts,
      bookmarkedPosts: bookmarkedPosts ?? this.bookmarkedPosts,
      commentsByPostId: commentsByPostId ?? this.commentsByPostId,
      commentsLoadingPostIds:
          commentsLoadingPostIds ?? this.commentsLoadingPostIds,
    );
  }

  @override
  List<Object?> get props => [
    posts,
    bookmarkedPosts,
    commentsByPostId,
    commentsLoadingPostIds,
  ];
}

class CommunityFailure extends CommunityState {
  const CommunityFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
