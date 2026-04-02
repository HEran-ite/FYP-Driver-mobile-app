library;

import '../../domain/entities/education_article.dart';
import '../../domain/repositories/education_repository.dart';

class GetEducationArticleUseCase {
  GetEducationArticleUseCase(this._repository);
  final EducationRepository _repository;

  Future<EducationArticle> call(String id) => _repository.getById(id);
}
