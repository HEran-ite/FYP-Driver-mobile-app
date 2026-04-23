library;

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/post_comment_model.dart';
import '../models/post_model.dart';
import 'community_remote_datasource.dart';

class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  CommunityRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<PostModel>> listPosts({
    int page = 1,
    int limit = 20,
    String? query,
  }) async {
    final normalizedQuery = query?.trim();
    final res = await _dio.get<dynamic>(
      ApiEndpoints.driverCommunityPosts,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (normalizedQuery != null && normalizedQuery.isNotEmpty)
          'search': normalizedQuery,
      },
    );
    return _mapPosts(res.data);
  }

  @override
  Future<List<PostModel>> listBookmarkedPosts({
    int page = 1,
    int limit = 20,
    String? query,
  }) async {
    final normalizedQuery = query?.trim();
    final res = await _dio.get<dynamic>(
      '${ApiEndpoints.driverCommunityPosts}/bookmarks/me',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (normalizedQuery != null && normalizedQuery.isNotEmpty)
          'search': normalizedQuery,
      },
    );
    return _mapPosts(res.data);
  }

  @override
  Future<void> createPost({
    required String title,
    required String content,
    String? imageUrl,
    String? imageFilePath,
  }) async {
    final filePath = imageFilePath?.trim();
    final hasFile =
        filePath != null && filePath.isNotEmpty && File(filePath).existsSync();

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

    final imagePayload = _imagePayload(imageUrl);

    // JSON fallback (backend accepts imageUrl/imageUrls).
    await _dio.post(
      ApiEndpoints.driverCommunityPosts,
      data: {
        'title': title,
        'content': content,
        ...imagePayload,
      },
    );
  }

  @override
  Future<void> editPost({
    required String id,
    String? title,
    String? content,
    String? imageUrl,
  }) async {
    final imagePayload = _imagePayload(imageUrl, includeEmpty: true);
    await _dio.put(
      '${ApiEndpoints.driverCommunityPosts}/$id',
      data: {
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        ...imagePayload,
      },
    );
  }

  @override
  Future<void> deletePost(String id) async {
    await _dio.delete('${ApiEndpoints.driverCommunityPosts}/$id');
  }

  @override
  Future<void> toggleLike(String id) async {
    await _dio.post('${ApiEndpoints.driverCommunityPosts}/$id/likes/toggle');
  }

  @override
  Future<void> toggleBookmark(String id) async {
    await _dio.post(
      '${ApiEndpoints.driverCommunityPosts}/$id/bookmarks/toggle',
    );
  }

  @override
  Future<void> reportPost({
    required String id,
    required String reason,
    String? details,
  }) async {
    await _dio.post(
      '${ApiEndpoints.driverCommunityPosts}/$id/report',
      data: {
        'reason': reason,
        if (details != null && details.trim().isNotEmpty)
          'details': details.trim(),
      },
    );
  }

  @override
  Future<List<PostCommentModel>> listComments(String postId) async {
    final res = await _dio.get<dynamic>(
      '${ApiEndpoints.driverCommunityPosts}/$postId/comments',
    );
    final list = _extractList(res.data);
    return list
        .map(
          (e) =>
              PostCommentModel.fromJson(e is Map<String, dynamic> ? e : null),
        )
        .where((c) => c.id.isNotEmpty)
        .toList();
  }

  @override
  Future<void> createComment({
    required String postId,
    required String content,
  }) async {
    await _dio.post(
      '${ApiEndpoints.driverCommunityPosts}/$postId/comments',
      data: {'content': content},
    );
  }

  @override
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    await _dio.delete(
      '${ApiEndpoints.driverCommunityPosts}/$postId/comments/$commentId',
    );
  }

  List<PostModel> _mapPosts(dynamic data) {
    final list = _extractList(data);
    return list
        .map((e) => PostModel.fromJson(e is Map<String, dynamic> ? e : null))
        .where((p) => p.id.isNotEmpty)
        .toList();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'] as List;
    return const [];
  }

  Map<String, dynamic> _imagePayload(
    String? imageUrl, {
    bool includeEmpty = false,
  }) {
    final raw = imageUrl?.trim();
    if (raw == null || raw.isEmpty) {
      if (!includeEmpty) return const {};
      return {'imageUrls': <String>[]};
    }

    if (raw.startsWith('[')) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final urls = decoded
              .map((e) => e?.toString().trim() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
          if (urls.isNotEmpty) {
            return {
              'imageUrls': urls,
              'imageUrl': urls.first,
            };
          }
          if (includeEmpty) {
            return {'imageUrls': <String>[]};
          }
        }
      } catch (_) {
        // Fallback to single-string behavior below.
      }
    }

    return {'imageUrl': raw};
  }
}
