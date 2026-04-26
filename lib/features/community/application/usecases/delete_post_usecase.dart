library;

import '../../domain/repositories/community_repository.dart';

class DeletePostUseCase {
  DeletePostUseCase(this._repo);
  final CommunityRepository _repo;

  Future<void> call(String id) => _repo.deletePost(id);
}
