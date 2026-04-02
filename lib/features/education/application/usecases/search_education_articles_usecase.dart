library;

import '../../domain/entities/education_article.dart';
import '../../domain/repositories/education_repository.dart';

class SearchEducationArticlesUseCase {
  SearchEducationArticlesUseCase(this._repository);
  final EducationRepository _repository;

  Future<List<EducationArticle>> call(String query) =>
      _repository.search(query.trim());
}
