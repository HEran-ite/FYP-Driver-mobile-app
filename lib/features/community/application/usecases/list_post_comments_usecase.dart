library;

import '../../domain/entities/post.dart';
import '../../domain/repositories/community_repository.dart';

class ListPostCommentsUseCase {
  ListPostCommentsUseCase(this._repo);
  final CommunityRepository _repo;

  Future<List<PostComment>> call(String postId) => _repo.listComments(postId);
}
