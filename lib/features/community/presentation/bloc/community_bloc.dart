library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../application/usecases/create_post_usecase.dart';
import '../../application/usecases/delete_post_usecase.dart';
import '../../application/usecases/list_posts_usecase.dart';
import 'community_event.dart';
import 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  CommunityBloc({
    required ListPostsUseCase listPostsUseCase,
    required CreatePostUseCase createPostUseCase,
    required DeletePostUseCase deletePostUseCase,
  })  : _list = listPostsUseCase,
        _create = createPostUseCase,
        _delete = deletePostUseCase,
        super(const CommunityInitial()) {
    on<CommunityLoadRequested>(_onLoad);
    on<CommunityRefreshRequested>(_onRefresh);
    on<CommunityCreatePostRequested>(_onCreate);
    on<CommunityDeletePostRequested>(_onDelete);
  }

  final ListPostsUseCase _list;
  final CreatePostUseCase _create;
  final DeletePostUseCase _delete;

  Future<void> _onLoad(CommunityLoadRequested event, Emitter<CommunityState> emit) async {
    emit(const CommunityLoading());
    try {
      final posts = await _list(page: 1, limit: 30);
      emit(CommunityLoaded(posts));
    } catch (e) {
      emit(CommunityFailure(_message(e)));
    }
  }

  Future<void> _onRefresh(
    CommunityRefreshRequested event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      final posts = await _list(page: 1, limit: 30);
      emit(CommunityLoaded(posts));
    } catch (e) {
      emit(CommunityFailure(_message(e)));
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
      final posts = await _list(page: 1, limit: 30);
      emit(CommunityLoaded(posts));
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
    if (current is! CommunityLoaded) return;
    try {
      await _delete(event.id);
      final updated = current.posts.where((p) => p.id != event.id).toList();
      emit(CommunityLoaded(updated));
    } catch (e) {
      emit(CommunityFailure(_message(e)));
      emit(current);
    }
  }

  String _message(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['error'] != null) return data['error'].toString();
      return e.message?.toString() ?? 'Request failed';
    }
    final s = e.toString();
    if (s.length < 140) return s;
    return 'Something went wrong.';
  }
}

