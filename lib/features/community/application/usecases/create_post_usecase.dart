library;

import '../../domain/repositories/community_repository.dart';

class CreatePostUseCase {
  CreatePostUseCase(this._repo);
  final CommunityRepository _repo;

  Future<void> call({
    required String title,
    required String content,
    String? imageUrl,
    String? imageFilePath,
  }) =>
      _repo.createPost(
        title: title,
        content: content,
        imageUrl: imageUrl,
        imageFilePath: imageFilePath,
      );
}

