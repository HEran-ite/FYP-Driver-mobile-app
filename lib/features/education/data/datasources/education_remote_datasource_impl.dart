library;

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/education_article_model.dart';
import 'education_remote_datasource.dart';

class EducationRemoteDataSourceImpl implements EducationRemoteDataSource {
  EducationRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  List<EducationArticleModel> _parseList(dynamic data) {
    final list = _extractList(data);
    return list
        .whereType<Map>()
        .map(
          (e) => EducationArticleModel.fromJson(Map<String, dynamic>.from(e)),
        )
        .where((m) => m.id.isNotEmpty)
        .toList();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final direct = data['data'];
      if (direct is List) return direct;
      final items = data['items'];
      if (items is List) return items;
      final result = data['result'];
      if (result is List) return result;
    }
    return const [];
  }

  @override
  Future<List<EducationArticleModel>> listAll() async {
    final data = await _getFirstSuccessful(
      endpoints: const [
        ApiEndpoints.driverEducation,
        ApiEndpoints.educationContent,
      ],
    );
    return _parseList(data);
  }

  @override
  Future<List<EducationArticleModel>> search(String query) async {
    try {
      final data = await _getFirstSuccessful(
        endpoints: const [
          ApiEndpoints.driverEducationSearch,
          '/education/content/search',
          '/driver/education/search',
          '/education/search',
        ],
        queryParameters: {'q': query},
      );
      return _parseList(data);
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
      final all = await listAll();
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return all;
      return all
          .where(
            (a) =>
                a.title.toLowerCase().contains(q) ||
                a.description.toLowerCase().contains(q),
          )
          .toList();
    }
  }

  @override
  Future<EducationArticleModel> getById(String id) async {
    final data = await _getFirstSuccessful(
      endpoints: [
        ApiEndpoints.driverEducationById(id),
        ApiEndpoints.educationContentById(id),
      ],
    );
    if (data is Map<String, dynamic>) {
      return EducationArticleModel.fromJson(data);
    }
    if (data is Map) return EducationArticleModel.fromJson(Map<String, dynamic>.from(data));
    throw DioException(
      requestOptions: RequestOptions(path: ApiEndpoints.driverEducationById(id)),
      type: DioExceptionType.unknown,
      error: 'Invalid education article response shape',
    );
  }

  Future<dynamic> _getFirstSuccessful({
    required List<String> endpoints,
    Map<String, dynamic>? queryParameters,
  }) async {
    DioException? lastError;
    for (final endpoint in endpoints) {
      try {
        final res = await _dio.get<dynamic>(
          endpoint,
          queryParameters: queryParameters,
        );
        return res.data;
      } on DioException catch (e) {
        final code = e.response?.statusCode;
        // Auth/session errors should surface immediately.
        if (code == 401 || code == 403) rethrow;
        // Try next endpoint on not found/bad request/server mismatch.
        if (code == 404 || code == 400 || code == 405 || code == 500) {
          lastError = e;
          continue;
        }
        rethrow;
      }
    }
    if (lastError != null) throw lastError;
    throw DioException(
      requestOptions: RequestOptions(path: endpoints.first),
      type: DioExceptionType.unknown,
      error: 'No education endpoint succeeded',
    );
  }
}
