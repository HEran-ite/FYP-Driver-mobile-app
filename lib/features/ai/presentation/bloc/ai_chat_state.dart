library;

import 'package:equatable/equatable.dart';

import '../../data/models/ai_message_model.dart';
import '../../data/models/ai_session_model.dart';

class AiChatState extends Equatable {
  const AiChatState({
    this.sessions = const [],
    this.currentSessionId,
    this.messages = const [],
    this.sessionsLoading = false,
    this.messagesLoading = false,
    this.sending = false,
    this.loadingOlder = false,
    this.deletingSessionId,
    this.hasMore = false,
    this.nextBefore,
    this.error,
  });

  final List<AiSessionModel> sessions;
  final String? currentSessionId;
  final List<AiMessageModel> messages;
  final bool sessionsLoading;
  final bool messagesLoading;
  final bool sending;
  final bool loadingOlder;
  final String? deletingSessionId;
  final bool hasMore;
  final String? nextBefore;
  final String? error;

  AiChatState copyWith({
    List<AiSessionModel>? sessions,
    String? currentSessionId,
    bool clearCurrentSessionId = false,
    List<AiMessageModel>? messages,
    bool? sessionsLoading,
    bool? messagesLoading,
    bool? sending,
    bool? loadingOlder,
    String? deletingSessionId,
    bool clearDeletingSessionId = false,
    bool? hasMore,
    String? nextBefore,
    bool clearNextBefore = false,
    String? error,
    bool clearError = false,
  }) {
    return AiChatState(
      sessions: sessions ?? this.sessions,
      currentSessionId: clearCurrentSessionId
          ? null
          : (currentSessionId ?? this.currentSessionId),
      messages: messages ?? this.messages,
      sessionsLoading: sessionsLoading ?? this.sessionsLoading,
      messagesLoading: messagesLoading ?? this.messagesLoading,
      sending: sending ?? this.sending,
      loadingOlder: loadingOlder ?? this.loadingOlder,
      deletingSessionId: clearDeletingSessionId
          ? null
          : (deletingSessionId ?? this.deletingSessionId),
      hasMore: hasMore ?? this.hasMore,
      nextBefore: clearNextBefore ? null : (nextBefore ?? this.nextBefore),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    sessions,
    currentSessionId,
    messages,
    sessionsLoading,
    messagesLoading,
    sending,
    loadingOlder,
    deletingSessionId,
    hasMore,
    nextBefore,
    error,
  ];
}
