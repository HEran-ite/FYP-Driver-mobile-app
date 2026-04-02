library;

import 'package:equatable/equatable.dart';

abstract class CommunityEvent extends Equatable {
  const CommunityEvent();
  @override
  List<Object?> get props => [];
}

class CommunityLoadRequested extends CommunityEvent {
  const CommunityLoadRequested();
}

class CommunityRefreshRequested extends CommunityEvent {
  const CommunityRefreshRequested();
}

class CommunityCreatePostRequested extends CommunityEvent {
  const CommunityCreatePostRequested({
    required this.title,
    required this.content,
    this.imageUrl,
    this.imageFilePath,
  });

  final String title;
  final String content;
  final String? imageUrl;
  final String? imageFilePath;

  @override
  List<Object?> get props => [title, content, imageUrl, imageFilePath];
}

class CommunityDeletePostRequested extends CommunityEvent {
  const CommunityDeletePostRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

