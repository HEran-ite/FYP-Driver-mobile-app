library;

import '../models/post_model.dart';

abstract class CommunityRemoteDataSource {
  Future<List<PostModel>> listPosts({int page = 1, int limit = 20});
  Future<void> createPost({
    required String title,
    required String content,
    String? imageUrl,
    String? imageFilePath,
  });
  Future<void> deletePost(String id);
}

