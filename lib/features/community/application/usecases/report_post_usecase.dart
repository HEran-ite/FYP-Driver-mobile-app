library;

import '../../domain/repositories/community_repository.dart';

class ReportPostUseCase {
  ReportPostUseCase(this._repo);
  final CommunityRepository _repo;

  Future<void> call({
    required String postId,
    required String reason,
    String? details,
  }) => _repo.reportPost(id: postId, reason: reason, details: details);
}
