library;

import '../../domain/repositories/community_repository.dart';

class CreatePostCommentUseCase {
  CreatePostCommentUseCase(this._repo);
  final CommunityRepository _repo;

  Future<void> call({required String postId, required String content}) =>
      _repo.createComment(postId: postId, content: content);
}
