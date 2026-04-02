library;

import 'package:equatable/equatable.dart';

import '../../domain/entities/education_article.dart';

abstract class EducationState extends Equatable {
  const EducationState();
  @override
  List<Object?> get props => [];
}

class EducationInitial extends EducationState {
  const EducationInitial();
}

class EducationLoading extends EducationState {
  const EducationLoading();
}

class EducationLoaded extends EducationState {
  const EducationLoaded({
    required this.articles,
    this.searchQuery,
  });

  final List<EducationArticle> articles;

  /// Non-null when the list came from search; empty string means user cleared search.
  final String? searchQuery;

  @override
  List<Object?> get props => [articles, searchQuery];
}

class EducationFailure extends EducationState {
  const EducationFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
