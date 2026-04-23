library;

import '../../domain/repositories/community_repository.dart';

class DeletePostCommentUseCase {
  DeletePostCommentUseCase(this._repo);
  final CommunityRepository _repo;

  Future<void> call({required String postId, required String commentId}) =>
      _repo.deleteComment(postId: postId, commentId: commentId);
}
