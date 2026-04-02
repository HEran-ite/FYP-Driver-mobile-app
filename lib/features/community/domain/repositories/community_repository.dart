library;

import '../entities/post.dart';

abstract class CommunityRepository {
  Future<List<Post>> listPosts({int page = 1, int limit = 20});
  Future<void> createPost({
    required String title,
    required String content,
    String? imageUrl,
    String? imageFilePath,
  });
  Future<void> deletePost(String id);
}

