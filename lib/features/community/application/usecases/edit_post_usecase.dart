library;

import '../../domain/repositories/community_repository.dart';

class EditPostUseCase {
  EditPostUseCase(this._repo);
  final CommunityRepository _repo;

  Future<void> call({
    required String id,
    String? title,
    String? content,
    String? imageUrl,
  }) => _repo.editPost(
    id: id,
    title: title,
    content: content,
    imageUrl: imageUrl,
  );
}
