library;

class AiMessageModel {
  const AiMessageModel({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String sessionId;
  final String role;
  final String content;
  final DateTime createdAt;

  bool get isUser {
    final r = role.toLowerCase();
    return r == 'user' || r == 'driver';
  }

  bool get isAssistant {
    final r = role.toLowerCase();
    return r == 'assistant' || r == 'ai' || r == 'bot';
  }

  factory AiMessageModel.fromJson(
    Map<String, dynamic> json, {
    String? fallbackSessionId,
  }) {
    String id =
        _asString(json['id']) ??
        _asString(json['_id']) ??
        _asString(json['messageId']) ??
        '';
    if (id.isEmpty) {
      id = DateTime.now().microsecondsSinceEpoch.toString();
    }

    final sessionId =
        _asString(json['sessionId']) ??
        _asString(json['session_id']) ??
        fallbackSessionId ??
        '';

    final role =
        _asString(json['role']) ??
        _asString(json['sender']) ??
        _asString(json['author']) ??
        'assistant';

    final content =
        _asString(json['content']) ??
        _asString(json['message']) ??
        _asString(json['text']) ??
        '';

    final createdAt =
        _asDateTime(json['createdAt']) ??
        _asDateTime(json['created_at']) ??
        _asDateTime(json['timestamp']) ??
        DateTime.now();

    return AiMessageModel(
      id: id,
      sessionId: sessionId,
      role: role,
      content: content,
      createdAt: createdAt,
    );
  }
}

String? _asString(dynamic v) {
  final s = v?.toString().trim();
  if (s == null || s.isEmpty) return null;
  return s;
}

DateTime? _asDateTime(dynamic v) {
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}
