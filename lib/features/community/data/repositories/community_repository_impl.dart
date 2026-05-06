library;

import '../../domain/entities/post.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_remote_datasource.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  CommunityRepositoryImpl(this._remote);
  final CommunityRemoteDataSource _remote;

  @override
  Future<List<Post>> listPosts({
    int page = 1,
    int limit = 20,
    String? query,
  }) async {
    final models = await _remote.listPosts(
      page: page,
      limit: limit,
      query: query,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Post>> listBookmarkedPosts({
    int page = 1,
    int limit = 20,
    String? query,
  }) async {
    final models = await _remote.listBookmarkedPosts(
      page: page,
      limit: limit,
      query: query,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> createPost({
    required String title,
    required String content,
    String? imageUrl,
    String? imageFilePath,
  }) => _remote.createPost(
    title: title,
    content: content,
    imageUrl: imageUrl,
    imageFilePath: imageFilePath,
  );

  @override
  Future<void> editPost({
    required String id,
    String? title,
    String? content,
    String? imageUrl,
  }) => _remote.editPost(
    id: id,
    title: title,
    content: content,
    imageUrl: imageUrl,
  );

  @override
  Future<void> deletePost(String id) => _remote.deletePost(id);

  @override
  Future<void> toggleLike(String id) => _remote.toggleLike(id);

  @override
  Future<void> toggleBookmark(String id) => _remote.toggleBookmark(id);

  @override
  Future<void> reportPost({
    required String id,
    required String reason,
    String? details,
  }) => _remote.reportPost(id: id, reason: reason, details: details);

  @override
  Future<List<PostComment>> listComments(String postId) async {
    final models = await _remote.listComments(postId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> createComment({
    required String postId,
    required String content,
  }) => _remote.createComment(postId: postId, content: content);

  @override
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) => _remote.deleteComment(postId: postId, commentId: commentId);
}
