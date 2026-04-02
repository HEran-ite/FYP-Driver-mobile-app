library;

import '../../domain/entities/post.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_remote_datasource.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  CommunityRepositoryImpl(this._remote);
  final CommunityRemoteDataSource _remote;

  @override
  Future<List<Post>> listPosts({int page = 1, int limit = 20}) async {
    final models = await _remote.listPosts(page: page, limit: limit);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> createPost({
    required String title,
    required String content,
    String? imageUrl,
    String? imageFilePath,
  }) =>
      _remote.createPost(
        title: title,
        content: content,
        imageUrl: imageUrl,
        imageFilePath: imageFilePath,
      );

  @override
  Future<void> deletePost(String id) => _remote.deletePost(id);
}

