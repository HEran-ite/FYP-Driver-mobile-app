library;

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/education_article_model.dart';
import 'education_remote_datasource.dart';

class EducationRemoteDataSourceImpl implements EducationRemoteDataSource {
  EducationRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  List<EducationArticleModel> _parseList(dynamic data) {
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((e) => EducationArticleModel.fromJson(Map<String, dynamic>.from(e)))
        .where((m) => m.id.isNotEmpty)
        .toList();
  }

  @override
  Future<List<EducationArticleModel>> listAll() async {
    final res = await _dio.get<dynamic>(ApiEndpoints.driverEducation);
    return _parseList(res.data);
  }

  @override
  Future<List<EducationArticleModel>> search(String query) async {
    final res = await _dio.get<dynamic>(
      ApiEndpoints.driverEducationSearch,
      queryParameters: {'q': query},
    );
    return _parseList(res.data);
  }

  @override
  Future<EducationArticleModel> getById(String id) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.driverEducationById(id),
    );
    final data = res.data;
    if (data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        type: DioExceptionType.unknown,
        error: 'Empty response',
      );
    }
    return EducationArticleModel.fromJson(data);
  }
}
