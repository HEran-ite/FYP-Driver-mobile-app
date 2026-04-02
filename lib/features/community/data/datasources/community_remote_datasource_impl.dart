library;

import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/post_model.dart';
import 'community_remote_datasource.dart';

class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  CommunityRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<PostModel>> listPosts({int page = 1, int limit = 20}) async {
    final res = await _dio.get<dynamic>(
      ApiEndpoints.driverCommunityPosts,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = res.data;
    if (data is List) {
      return data
          .map((e) => PostModel.fromJson(e is Map<String, dynamic> ? e : null))
          .where((p) => p.id.isNotEmpty)
          .toList();
    }
    if (data is Map && data['data'] is List) {
      final list = data['data'] as List;
      return list
          .map((e) => PostModel.fromJson(e is Map<String, dynamic> ? e : null))
          .where((p) => p.id.isNotEmpty)
          .toList();
    }
    return const [];
  }

  @override
  Future<void> createPost({
    required String title,
    required String content,
    String? imageUrl,
    String? imageFilePath,
  }) async {
    final filePath = imageFilePath?.trim();
    final hasFile = filePath != null && filePath.isNotEmpty && File(filePath).existsSync();

    // Try multipart first if we have a file. This will only work if backend supports multipart.
    if (hasFile) {
      try {
        final form = FormData.fromMap({
          'title': title,
          'content': content,
          'image': await MultipartFile.fromFile(
            filePath,
            filename: filePath.split(RegExp(r'[/\\]')).last,
          ),
        });
        await _dio.post(
          ApiEndpoints.driverCommunityPosts,
          data: form,
          options: Options(contentType: 'multipart/form-data'),
        );
        return;
      } on DioException {
        // Fall back to JSON payload below.
      }
    }

    // JSON fallback (backend currently expects imageUrl string).
    await _dio.post(
      ApiEndpoints.driverCommunityPosts,
      data: {
        'title': title,
        'content': content,
        if (imageUrl != null && imageUrl.trim().isNotEmpty) 'imageUrl': imageUrl.trim(),
      },
    );
  }

  @override
  Future<void> deletePost(String id) async {
    await _dio.delete('${ApiEndpoints.driverCommunityPosts}/$id');
  }
}

