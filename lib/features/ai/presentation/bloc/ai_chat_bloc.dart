library;

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/ai_message_model.dart';
import '../../data/models/ai_session_model.dart';
import '../../data/repositories/ai_chat_repository.dart';
import 'ai_chat_event.dart';
import 'ai_chat_state.dart';

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  AiChatBloc(this._repo) : super(const AiChatState()) {
    on<AiSessionsRequested>(_onSessionsRequested);
    on<AiSessionSelected>(_onSessionSelected);
    on<AiStartSessionRequested>(_onStartSessionRequested);
    on<AiMessagesRequested>(_onMessagesRequested);
    on<AiOlderMessagesRequested>(_onOlderMessagesRequested);
    on<AiSessionDeleteRequested>(_onSessionDeleteRequested);
    on<AiMessageSendRequested>(_onMessageSendRequested);
  }

  final AiChatRepository _repo;
  
  String _message(Object e) {
    if (e is DioException) {
      final code = e.response?.statusCode;
      final data = e.response?.data;
      if (code == 401 || code == 403) {
        return 'AI service unauthorized. Please login again.';
      }
      if (data is Map && data['error'] != null) {
        return data['error'].toString();
      }
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (code != null) return 'AI request failed (HTTP $code).';
    }
    final s = e.toString();
    if (s.length > 180) return 'AI request failed.';
    return s;
  }

  Future<void> _onSessionsRequested(
    AiSessionsRequested event,
    Emitter<AiChatState> emit,
  ) async {
    emit(state.copyWith(sessionsLoading: true, clearError: true));
    try {
      final sessions = await _repo.listSessions();
      final shouldAutoSelectLatest =
          (state.currentSessionId == null || state.currentSessionId!.isEmpty) &&
          sessions.isNotEmpty;
      final latestSessionId = shouldAutoSelectLatest ? sessions.first.id : null;
      emit(state.copyWith(
        sessions: sessions,
        currentSessionId: latestSessionId,
        sessionsLoading: false,
      ));
      if (latestSessionId != null) {
        add(AiMessagesRequested(sessionId: latestSessionId, refresh: true));
      }
    } catch (e) {
      emit(state.copyWith(
        sessionsLoading: false,
        error: _message(e),
      ));
    }
  }

  Future<void> _onSessionSelected(
    AiSessionSelected event,
    Emitter<AiChatState> emit,
  ) async {
    emit(state.copyWith(currentSessionId: event.sessionId));
    add(AiMessagesRequested(sessionId: event.sessionId, refresh: true));
  }

  Future<void> _onStartSessionRequested(
    AiStartSessionRequested event,
    Emitter<AiChatState> emit,
  ) async {
    emit(state.copyWith(messagesLoading: true, clearError: true));
    try {
      final session = await _repo.createSession(
        vehicleId: event.vehicleId,
        title: event.title,
      );
      final sessions = <AiSessionModel>[
        session,
        ...state.sessions.where((s) => s.id != session.id),
      ];
      emit(
        state.copyWith(
          sessions: sessions,
          currentSessionId: session.id,
          messages: const [],
          hasMore: false,
          messagesLoading: false,
          clearNextBefore: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        messagesLoading: false,
        error: _message(e),
      ));
    }
  }

  Future<void> _onMessagesRequested(
    AiMessagesRequested event,
    Emitter<AiChatState> emit,
  ) async {
    if (event.refresh) {
      emit(state.copyWith(
        currentSessionId: event.sessionId,
        messagesLoading: true,
        clearError: true,
      ));
    }
    try {
      final page = await _repo.getMessages(event.sessionId);
      final items = _normalizeChronological(page.items);
      emit(state.copyWith(
        currentSessionId: event.sessionId,
        messages: items,
        hasMore: page.hasMore,
        nextBefore: page.nextBefore,
        messagesLoading: false,
        loadingOlder: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        messagesLoading: false,
        loadingOlder: false,
        error: _message(e),
      ));
    }
  }

  Future<void> _onOlderMessagesRequested(
    AiOlderMessagesRequested event,
    Emitter<AiChatState> emit,
  ) async {
    final sid = state.currentSessionId;
    final before = state.nextBefore;
    if (sid == null || sid.isEmpty || !state.hasMore || state.loadingOlder) return;
    emit(state.copyWith(loadingOlder: true, clearError: true));
    try {
      final page = await _repo.getMessages(sid, before: before);
      final combined = <AiMessageModel>[
        ..._normalizeChronological(page.items),
        ...state.messages,
      ];
      emit(state.copyWith(
        messages: _dedupeMessages(combined),
        hasMore: page.hasMore,
        nextBefore: page.nextBefore,
        loadingOlder: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        loadingOlder: false,
        error: _message(e),
      ));
    }
  }

  Future<void> _onMessageSendRequested(
    AiMessageSendRequested event,
    Emitter<AiChatState> emit,
  ) async {
    final text = event.message.trim();
    if (text.isEmpty || state.sending) return;

    var sid = state.currentSessionId;
    if (sid == null || sid.isEmpty) {
      emit(state.copyWith(messagesLoading: true, clearError: true));
      try {
        final s = await _repo.createSession(
          vehicleId: event.vehicleId,
          title: event.sessionTitle,
        );
        sid = s.id;
        final sessions = <AiSessionModel>[
          s,
          ...state.sessions.where((x) => x.id != s.id),
        ];
        emit(state.copyWith(
          sessions: sessions,
          currentSessionId: sid,
          messagesLoading: false,
        ));
      } catch (e) {
        emit(state.copyWith(
          messagesLoading: false,
          error: _message(e),
        ));
        return;
      }
    }

    final optimistic = AiMessageModel(
      id: 'local-user-${DateTime.now().microsecondsSinceEpoch}',
      sessionId: sid,
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    );

    final optimisticMessages = [...state.messages, optimistic];

    emit(state.copyWith(
      currentSessionId: sid,
      messages: optimisticMessages,
      sending: true,
      clearError: true,
    ));

    try {
      final result = await _repo.sendMessage(sid, message: text);
      var nextMessages = optimisticMessages;
      final assistant = result.assistantMessage;
      if (assistant != null && assistant.content.trim().isNotEmpty) {
        nextMessages = [...nextMessages, assistant];
      }
      nextMessages = _dedupeMessages(nextMessages);

      final sessions = [...state.sessions];
      final idx = sessions.indexWhere((s) => s.id == sid);
      final base = idx >= 0
          ? sessions[idx]
          : AiSessionModel(
              id: sid,
              title: 'Chat Session',
              updatedAt: DateTime.now(),
            );
      final updatedSession = (result.session ?? base).copyWith(
        lastMessagePreview: assistant?.content ?? text,
        updatedAt: DateTime.now(),
      );
      if (idx >= 0) {
        sessions.removeAt(idx);
      }
      sessions.insert(0, updatedSession);

      emit(state.copyWith(
        sessions: sessions,
        messages: nextMessages,
        sending: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        sending: false,
        error: _message(e),
      ));
    }
  }

  Future<void> _onSessionDeleteRequested(
    AiSessionDeleteRequested event,
    Emitter<AiChatState> emit,
  ) async {
    final sid = event.sessionId.trim();
    if (sid.isEmpty || state.deletingSessionId != null) return;

    emit(state.copyWith(
      deletingSessionId: sid,
      clearError: true,
    ));
    try {
      await _repo.deleteSession(sid);
      final nextSessions = state.sessions.where((s) => s.id != sid).toList();
      final deletingCurrent = state.currentSessionId == sid;
      emit(state.copyWith(
        sessions: nextSessions,
        currentSessionId: deletingCurrent ? null : state.currentSessionId,
        clearCurrentSessionId: deletingCurrent,
        messages: deletingCurrent ? const [] : state.messages,
        hasMore: deletingCurrent ? false : state.hasMore,
        clearNextBefore: deletingCurrent,
        clearDeletingSessionId: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        clearDeletingSessionId: true,
        error: _message(e),
      ));
    }
  }

  List<AiMessageModel> _dedupeMessages(List<AiMessageModel> list) {
    final seen = <String>{};
    final out = <AiMessageModel>[];
    for (final m in list) {
      if (seen.add(m.id)) {
        out.add(m);
      }
    }
    return out;
  }

  List<AiMessageModel> _normalizeChronological(List<AiMessageModel> items) {
    if (items.length < 2) return items.toList();
    var ascPairs = 0;
    var descPairs = 0;
    for (var i = 1; i < items.length; i++) {
      final prev = items[i - 1].createdAt;
      final curr = items[i].createdAt;
      if (curr.isAfter(prev)) ascPairs++;
      if (curr.isBefore(prev)) descPairs++;
    }
    if (descPairs > ascPairs) {
      return items.reversed.toList();
    }
    return items.toList();
  }
}
