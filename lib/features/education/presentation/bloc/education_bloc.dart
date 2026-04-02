library;

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import '../../application/usecases/list_education_articles_usecase.dart';
import '../../application/usecases/search_education_articles_usecase.dart';
import 'education_event.dart';
import 'education_state.dart';

class EducationBloc extends Bloc<EducationEvent, EducationState> {
  EducationBloc({
    required ListEducationArticlesUseCase listArticles,
    required SearchEducationArticlesUseCase searchArticles,
  })  : _listArticles = listArticles,
        _searchArticles = searchArticles,
        super(const EducationInitial()) {
    on<EducationLoadRequested>(_onLoad);
    on<EducationSearchSubmitted>(_onSearch);
    on<EducationSearchCleared>(_onClearSearch);
  }

  final ListEducationArticlesUseCase _listArticles;
  final SearchEducationArticlesUseCase _searchArticles;

  Future<void> _onLoad(
    EducationLoadRequested event,
    Emitter<EducationState> emit,
  ) async {
    final silent = state is EducationLoaded;
    if (!silent) emit(const EducationLoading());
    try {
      final articles = await _listArticles();
      emit(EducationLoaded(articles: articles, searchQuery: null));
    } catch (e) {
      emit(EducationFailure(_message(e)));
    }
  }

  Future<void> _onSearch(
    EducationSearchSubmitted event,
    Emitter<EducationState> emit,
  ) async {
    final q = event.query.trim();
    try {
      if (q.isEmpty) {
        final articles = await _listArticles();
        emit(EducationLoaded(articles: articles, searchQuery: null));
        return;
      }
      final articles = await _searchArticles(q);
      emit(EducationLoaded(articles: articles, searchQuery: q));
    } catch (e) {
      emit(EducationFailure(_message(e)));
    }
  }

  Future<void> _onClearSearch(
    EducationSearchCleared event,
    Emitter<EducationState> emit,
  ) async {
    try {
      final articles = await _listArticles();
      emit(EducationLoaded(articles: articles, searchQuery: null));
    } catch (e) {
      emit(EducationFailure(_message(e)));
    }
  }

  String _message(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (data is Map && data['error'] != null) {
        return data['error'].toString();
      }
    }
    return e.toString().contains('SocketException') ||
            e.toString().contains('Connection')
        ? 'Network error.'
        : 'Could not load education content.';
  }
}
