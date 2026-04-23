library;

import '../models/post_model.dart';
import '../models/post_comment_model.dart';

abstract class CommunityRemoteDataSource {
  Future<List<PostModel>> listPosts({
    int page = 1,
    int limit = 20,
    String? query,
  });
  Future<List<PostModel>> listBookmarkedPosts({
    int page = 1,
    int limit = 20,
    String? query,
  });
  Future<void> createPost({
    required String title,
    required String content,
    String? imageUrl,
    String? imageFilePath,
  });
  Future<void> editPost({
    required String id,
    String? title,
    String? content,
    String? imageUrl,
  });
  Future<void> deletePost(String id);
  Future<void> toggleLike(String id);
  Future<void> toggleBookmark(String id);
  Future<void> reportPost({
    required String id,
    required String reason,
    String? details,
  });
  Future<List<PostCommentModel>> listComments(String postId);
  Future<void> createComment({required String postId, required String content});
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  });
}
