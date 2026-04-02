library;

import 'package:equatable/equatable.dart';

abstract class EducationEvent extends Equatable {
  const EducationEvent();
  @override
  List<Object?> get props => [];
}

class EducationLoadRequested extends EducationEvent {
  const EducationLoadRequested();
}

/// Server-side search (`GET /driver/education/search?q=`).
class EducationSearchSubmitted extends EducationEvent {
  const EducationSearchSubmitted(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class EducationSearchCleared extends EducationEvent {
  const EducationSearchCleared();
}
