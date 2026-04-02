library;

import '../models/education_article_model.dart';

abstract class EducationRemoteDataSource {
  Future<List<EducationArticleModel>> listAll();
  Future<List<EducationArticleModel>> search(String query);
  Future<EducationArticleModel> getById(String id);
}
