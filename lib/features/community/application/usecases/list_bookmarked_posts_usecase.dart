library;

import '../../domain/entities/post.dart';
import '../../domain/repositories/community_repository.dart';

class ListBookmarkedPostsUseCase {
  ListBookmarkedPostsUseCase(this._repo);
  final CommunityRepository _repo;

  Future<List<Post>> call({int page = 1, int limit = 20, String? query}) =>
      _repo.listBookmarkedPosts(page: page, limit: limit, query: query);
}
