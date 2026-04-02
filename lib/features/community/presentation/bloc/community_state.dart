library;

import 'package:equatable/equatable.dart';

import '../../domain/entities/post.dart';

abstract class CommunityState extends Equatable {
  const CommunityState();
  @override
  List<Object?> get props => [];
}

class CommunityInitial extends CommunityState {
  const CommunityInitial();
}

class CommunityLoading extends CommunityState {
  const CommunityLoading();
}

class CommunityLoaded extends CommunityState {
  const CommunityLoaded(this.posts);
  final List<Post> posts;

  @override
  List<Object?> get props => [posts];
}

class CommunityFailure extends CommunityState {
  const CommunityFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

