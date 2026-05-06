library;

import '../ai_api_client.dart';
import '../models/ai_message_model.dart';
import '../models/ai_paged_messages_model.dart';
import '../models/ai_session_model.dart';

class AiSendMessageResult {
  const AiSendMessageResult({
    this.assistantMessage,
    this.session,
  });

  final AiMessageModel? assistantMessage;
  final AiSessionModel? session;
}

class AiChatRepository {
  AiChatRepository(this._api);

  final AiApiClient _api;

  Future<AiSessionModel> createSession({
    String? vehicleId,
    String? title,
  }) async {
    final json = await _api.createSession(vehicleId: vehicleId, title: title);
    return AiSessionModel.fromJson(json);
  }

  Future<List<AiSessionModel>> listSessions() async {
    final rows = await _api.listSessions();
    return rows.map(AiSessionModel.fromJson).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<AiPagedMessagesModel> getMessages(
    String sessionId, {
    String? before,
  }) async {
    final json = await _api.getMessages(sessionId, before: before);
    return AiPagedMessagesModel.fromJson(json, sessionId: sessionId);
  }

  Future<AiSendMessageResult> sendMessage(
    String sessionId, {
    required String message,
    String? vehicleId,
  }) async {
    final json = await _api.sendMessage(
      sessionId,
      message: message,
      vehicleId: vehicleId,
    );

    AiSessionModel? session;
    final s = json['session'];
    if (s is Map) {
      session = AiSessionModel.fromJson(Map<String, dynamic>.from(s));
    }

    AiMessageModel? assistant;

    final assistantMessage = json['assistant_message'];
    if (assistantMessage is Map) {
      assistant = AiMessageModel.fromJson(
        Map<String, dynamic>.from(assistantMessage),
        fallbackSessionId: sessionId,
      );
    }

    if (assistant == null) {
      final reply = json['reply'];
      if (reply is String && reply.trim().isNotEmpty) {
        assistant = AiMessageModel(
          id: 'assistant-${DateTime.now().microsecondsSinceEpoch}',
          sessionId: sessionId,
          role: 'assistant',
          content: reply.trim(),
          createdAt: DateTime.now(),
        );
      }
    }

    if (assistant == null) {
      final content = json['content'];
      final role = json['role']?.toString().toLowerCase();
      if (content is String &&
          content.trim().isNotEmpty &&
          (role == null || role == 'assistant')) {
        assistant = AiMessageModel(
          id: 'assistant-${DateTime.now().microsecondsSinceEpoch}',
          sessionId: sessionId,
          role: 'assistant',
          content: content.trim(),
          createdAt: DateTime.now(),
        );
      }
    }

    return AiSendMessageResult(assistantMessage: assistant, session: session);
  }

  Future<void> deleteSession(String sessionId) {
    return _api.deleteSession(sessionId);
  }
}
