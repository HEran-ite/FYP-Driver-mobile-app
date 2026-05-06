library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/post.dart';
import '../../application/usecases/create_post_comment_usecase.dart';
import '../../application/usecases/create_post_usecase.dart';
import '../../application/usecases/delete_post_usecase.dart';
import '../../application/usecases/delete_post_comment_usecase.dart';
import '../../application/usecases/edit_post_usecase.dart';
import '../../application/usecases/list_posts_usecase.dart';
import '../../application/usecases/list_bookmarked_posts_usecase.dart';
import '../../application/usecases/list_post_comments_usecase.dart';
import '../../application/usecases/report_post_usecase.dart';
import '../../application/usecases/toggle_post_bookmark_usecase.dart';
import '../../application/usecases/toggle_post_like_usecase.dart';
import 'community_event.dart';
import 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  CommunityBloc({
    required ListPostsUseCase listPostsUseCase,
    required ListBookmarkedPostsUseCase listBookmarkedPostsUseCase,
    required CreatePostUseCase createPostUseCase,
    required EditPostUseCase editPostUseCase,
    required DeletePostUseCase deletePostUseCase,
    required TogglePostLikeUseCase togglePostLikeUseCase,
    required TogglePostBookmarkUseCase togglePostBookmarkUseCase,
    required ReportPostUseCase reportPostUseCase,
    required ListPostCommentsUseCase listPostCommentsUseCase,
    required CreatePostCommentUseCase createPostCommentUseCase,
    required DeletePostCommentUseCase deletePostCommentUseCase,
  }) : _list = listPostsUseCase,
       _listBookmarked = listBookmarkedPostsUseCase,
       _create = createPostUseCase,
       _edit = editPostUseCase,
       _delete = deletePostUseCase,
       _toggleLike = togglePostLikeUseCase,
       _toggleBookmark = togglePostBookmarkUseCase,
       _report = reportPostUseCase,
       _listComments = listPostCommentsUseCase,
       _createComment = createPostCommentUseCase,
       _deleteComment = deletePostCommentUseCase,
       super(const CommunityInitial()) {
    on<CommunityLoadRequested>(_onLoad);
    on<CommunityRefreshRequested>(_onRefresh);
    on<CommunitySearchRequested>(_onSearch);
    on<CommunityCreatePostRequested>(_onCreate);
    on<CommunityEditPostRequested>(_onEdit);
    on<CommunityDeletePostRequested>(_onDelete);
    on<CommunityToggleLikeRequested>(_onToggleLike);
    on<CommunityToggleBookmarkRequested>(_onToggleBookmark);
    on<CommunityReportPostRequested>(_onReportPost);
    on<CommunityCommentsLoadRequested>(_onCommentsLoad);
    on<CommunityCreateCommentRequested>(_onCreateComment);
    on<CommunityDeleteCommentRequested>(_onDeleteComment);
  }

  final ListPostsUseCase _list;
  final ListBookmarkedPostsUseCase _listBookmarked;
  final CreatePostUseCase _create;
  final EditPostUseCase _edit;
  final DeletePostUseCase _delete;
  final TogglePostLikeUseCase _toggleLike;
  final TogglePostBookmarkUseCase _toggleBookmark;
  final ReportPostUseCase _report;
  final ListPostCommentsUseCase _listComments;
  final CreatePostCommentUseCase _createComment;
  final DeletePostCommentUseCase _deleteComment;
  String _activeSearchQuery = '';

  Future<void> _onLoad(
    CommunityLoadRequested event,
    Emitter<CommunityState> emit,
  ) async {
    emit(const CommunityLoading());
    try {
      emit(await _loadState());
    } catch (e) {
      emit(CommunityFailure(_message(e)));
    }
  }

  Future<void> _onRefresh(
    CommunityRefreshRequested event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      emit(await _loadState(preserveFrom: state));
    } catch (e) {
      emit(CommunityFailure(_message(e)));
    }
  }

  Future<void> _onSearch(
    CommunitySearchRequested event,
    Emitter<CommunityState> emit,
  ) async {
    final normalized = event.query.trim();
    if (normalized == _activeSearchQuery) return;
    _activeSearchQuery = normalized;
    final current = state;
    try {
      if (current is! CommunityLoaded) {
        emit(const CommunityLoading());
      }
      emit(await _loadState(preserveFrom: current));
    } catch (e) {
      emit(CommunityFailure(_message(e)));
      if (current is CommunityLoaded) emit(current);
    }
  }

  Future<void> _onCreate(
    CommunityCreatePostRequested event,
    Emitter<CommunityState> emit,
  ) async {
    final current = state;
    try {
      await _create(
        title: event.title,
        content: event.content,
        imageUrl: event.imageUrl,
        imageFilePath: event.imageFilePath,
      );
      emit(await _loadState(preserveFrom: current));
    } catch (e) {
      emit(CommunityFailure(_message(e)));
      if (current is CommunityLoaded) emit(current);
    }
  }

  Future<void> _onEdit(
    CommunityEditPostRequested event,
    Emitter<CommunityState> emit,
  ) async {
    final current = state;
    try {
      await _edit(
        id: event.id,
        title: event.title,
        content: event.content,
        imageUrl: event.imageUrl,
      );
      emit(await _loadState(preserveFrom: current));
    } catch (e) {
      emit(CommunityFailure(_message(e)));
      if (current is CommunityLoaded) emit(current);
    }
  }

  Future<void> _onDelete(
    CommunityDeletePostRequested event,
    Emitter<CommunityState> emit,
  ) async {
    final current = state;
    try {
      await _delete(event.id);
      emit(await _loadState(preserveFrom: current));
    } catch (e) {
      emit(CommunityFailure(_message(e)));
      if (current is CommunityLoaded) emit(current);
    }
  }

  Future<void> _onToggleLike(
    CommunityToggleLikeRequested event,
    Emitter<CommunityState> emit,
  ) async {
    final current = state;
    try {
      await _toggleLike(event.postId);
      emit(await _loadState(preserveFrom: current));
    } catch (e) {
      emit(CommunityFailure(_message(e)));
      if (current is CommunityLoaded) emit(current);
    }
  }

  Future<void> _onToggleBookmark(
    CommunityToggleBookmarkRequested event,
    Emitter<CommunityState> emit,
  ) async {
    final current = state;
    try {
      await _toggleBookmark(event.postId);
      emit(await _loadState(preserveFrom: current));
    } catch (e) {
      emit(CommunityFailure(_message(e)));
      if (current is CommunityLoaded) emit(current);
    }
  }

  Future<void> _onReportPost(
    CommunityReportPostRequested event,
    Emitter<CommunityState> emit,
  ) async {
    final current = state;
    try {
      await _report(
        postId: event.postId,
        reason: event.reason,
        details: event.details,
      );
      if (current is CommunityLoaded) emit(current);
    } catch (e) {
      emit(CommunityFailure(_message(e)));
      if (current is CommunityLoaded) emit(current);
    }
  }

  Future<void> _onCommentsLoad(
    CommunityCommentsLoadRequested event,
    Emitter<CommunityState> emit,
  ) async {
    final current = state;
    if (current is! CommunityLoaded) return;
    final loading = {...current.commentsLoadingPostIds, event.postId};
    emit(current.copyWith(commentsLoadingPostIds: loading));
    try {
      final comments = await _listComments(event.postId);
      final map = Map<String, List<PostComment>>.from(current.commentsByPostId)
        ..[event.postId] = comments;
      final updatedLoading = Set<String>.from(loading)..remove(event.postId);
      emit(
        current.copyWith(
          commentsByPostId: map,
          commentsLoadingPostIds: updatedLoading,
        ),
      );
    } catch (e) {
      final updatedLoading = Set<String>.from(loading)..remove(event.postId);
      emit(CommunityFailure(_message(e)));
      emit(current.copyWith(commentsLoadingPostIds: updatedLoading));
    }
  }

  Future<void> _onCreateComment(
    CommunityCreateCommentRequested event,
    Emitter<CommunityState> emit,
  ) async {
    final current = state;
    if (current is! CommunityLoaded) return;
    try {
      await _createComment(postId: event.postId, content: event.content);
      final comments = await _listComments(event.postId);
      final map = Map<String, List<PostComment>>.from(current.commentsByPostId)
        ..[event.postId] = comments;
      final loaded = await _loadState(preserveFrom: current);
      emit(loaded.copyWith(commentsByPostId: map));
    } catch (e) {
      emit(CommunityFailure(_message(e)));
      emit(current);
    }
  }

  Future<void> _onDeleteComment(
    CommunityDeleteCommentRequested event,
    Emitter<CommunityState> emit,
  ) async {
    final current = state;
    if (current is! CommunityLoaded) return;
    try {
      await _deleteComment(postId: event.postId, commentId: event.commentId);
      final comments = await _listComments(event.postId);
      final map = Map<String, List<PostComment>>.from(current.commentsByPostId)
        ..[event.postId] = comments;
      final loaded = await _loadState(preserveFrom: current);
      emit(loaded.copyWith(commentsByPostId: map));
    } catch (e) {
      emit(CommunityFailure(_message(e)));
      emit(current);
    }
  }

  Future<CommunityLoaded> _loadState({CommunityState? preserveFrom}) async {
    final query = _activeSearchQuery.isEmpty ? null : _activeSearchQuery;
    final posts = await _list(page: 1, limit: 30, query: query);
    final bookmarked = await _listBookmarked(page: 1, limit: 30, query: query);
    final prev = preserveFrom is CommunityLoaded ? preserveFrom : null;
    return CommunityLoaded(
      posts: posts,
      bookmarkedPosts: bookmarked,
      commentsByPostId: prev?.commentsByPostId ?? const {},
      commentsLoadingPostIds: const {},
    );
  }

  String _message(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['error'] != null) return data['error'].toString();
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return e.message?.toString() ?? 'Request failed';
    }
    final s = e.toString();
    if (s.length < 140) return s;
    return 'Something went wrong.';
  }
}
