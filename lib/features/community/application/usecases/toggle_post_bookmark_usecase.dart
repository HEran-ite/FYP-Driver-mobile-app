library;

import '../../domain/repositories/community_repository.dart';

class TogglePostBookmarkUseCase {
  TogglePostBookmarkUseCase(this._repo);
  final CommunityRepository _repo;

  Future<void> call(String postId) => _repo.toggleBookmark(postId);
}
