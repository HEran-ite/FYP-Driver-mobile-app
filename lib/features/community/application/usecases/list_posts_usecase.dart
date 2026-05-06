library;

import '../../domain/entities/post.dart';
import '../../domain/repositories/community_repository.dart';

class ListPostsUseCase {
  ListPostsUseCase(this._repo);
  final CommunityRepository _repo;

  Future<List<Post>> call({int page = 1, int limit = 20, String? query}) =>
      _repo.listPosts(page: page, limit: limit, query: query);
}
