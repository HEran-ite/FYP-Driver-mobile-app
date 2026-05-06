library;

import '../../domain/repositories/community_repository.dart';

class TogglePostLikeUseCase {
  TogglePostLikeUseCase(this._repo);
  final CommunityRepository _repo;

  Future<void> call(String postId) => _repo.toggleLike(postId);
}
