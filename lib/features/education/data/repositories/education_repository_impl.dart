library;

import '../../domain/entities/education_article.dart';
import '../../domain/repositories/education_repository.dart';
import '../datasources/education_remote_datasource.dart';

class EducationRepositoryImpl implements EducationRepository {
  EducationRepositoryImpl(this._remote);

  final EducationRemoteDataSource _remote;

  @override
  Future<List<EducationArticle>> listAll() async {
    final list = await _remote.listAll();
    return list.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<EducationArticle>> search(String query) async {
    final list = await _remote.search(query);
    return list.map((m) => m.toEntity()).toList();
  }

  @override
  Future<EducationArticle> getById(String id) async {
    final m = await _remote.getById(id);
    return m.toEntity();
  }
}
