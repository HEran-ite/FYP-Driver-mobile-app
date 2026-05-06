library;

import 'ai_message_model.dart';

class AiPagedMessagesModel {
  const AiPagedMessagesModel({
    required this.items,
    required this.hasMore,
    this.nextBefore,
  });

  final List<AiMessageModel> items;
  final bool hasMore;
  final String? nextBefore;

  factory AiPagedMessagesModel.fromJson(
    Map<String, dynamic> json, {
    String? sessionId,
  }) {
    final rawItems = _messageListFrom(json);
    final items = rawItems
        .whereType<Map>()
        .map(
          (e) => AiMessageModel.fromJson(
            Map<String, dynamic>.from(e),
            fallbackSessionId: sessionId,
          ),
        )
        .toList();

    return AiPagedMessagesModel(
      items: items,
      hasMore: _asBool(json['has_more']) ?? _asBool(json['hasMore']) ?? false,
      nextBefore:
          _asString(json['next_before']) ?? _asString(json['nextBefore']),
    );
  }
}

List<dynamic> _messageListFrom(Map<String, dynamic> json) {
  for (final key in ['items', 'messages', 'results', 'data']) {
    final v = json[key];
    if (v is List) return v;
  }
  return const [];
}

String? _asString(dynamic v) {
  final s = v?.toString().trim();
  if (s == null || s.isEmpty) return null;
  return s;
}

bool? _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final t = v.trim().toLowerCase();
    if (t == 'true' || t == '1') return true;
    if (t == 'false' || t == '0') return false;
  }
  return null;
}
