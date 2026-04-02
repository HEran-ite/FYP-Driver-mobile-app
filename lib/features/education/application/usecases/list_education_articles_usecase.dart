library;

import '../../domain/entities/education_article.dart';
import '../../domain/repositories/education_repository.dart';

class ListEducationArticlesUseCase {
  ListEducationArticlesUseCase(this._repository);
  final EducationRepository _repository;

  Future<List<EducationArticle>> call() => _repository.listAll();
}
