library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/ai_message_model.dart';
import '../models/ai_session_model.dart';

/// Persists the last AI chat sessions + per-session messages so offline / failed
/// requests still show the previous conversation instead of an empty "new" chat.
class AiChatLocalCache {
  static const _prefsKey = 'driver_ai_chat_cache_v1';
  static const _maxMessagesPerSession = 400;

  Future<_CacheDoc?> _read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return null;
      return _CacheDoc.fromJson(Map<String, dynamic>.from(map));
    } catch (_) {
      return null;
    }
  }

  Future<void> _write(_CacheDoc doc) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(doc.toJson()));
  }

  Future<void> upsertSessions(
    List<AiSessionModel> sessions,
    String? currentSessionId,
  ) async {
    final doc = await _read() ?? _CacheDoc.empty();
    doc.sessionMaps = sessions.map(_sessionToMap).toList();
    final sid = currentSessionId?.trim();
    if (sid != null && sid.isNotEmpty) {
      doc.currentSessionId = sid;
    } else if (sessions.isEmpty) {
      doc.currentSessionId = null;
    }
    final ids = sessions.map((s) => s.id).toSet();
    doc.messagesBySessionId.removeWhere((k, _) => !ids.contains(k));
    doc.paginationBySessionId.removeWhere((k, _) => !ids.contains(k));
    await _write(doc);
  }

  Future<void> upsertThread(
    String sessionId,
    List<AiMessageModel> messages, {
    required bool hasMore,
    String? nextBefore,
  }) async {
    final sid = sessionId.trim();
    if (sid.isEmpty) return;
    final doc = await _read() ?? _CacheDoc.empty();
    doc.messagesBySessionId[sid] = _trimMessages(messages.map(_messageToMap).toList());
    doc.paginationBySessionId[sid] = _Pagination(
      hasMore: hasMore,
      nextBefore: nextBefore,
    );
    await _write(doc);
  }

  /// Full restore when listing sessions fails (e.g. offline).
  Future<AiChatRestoreSnapshot?> loadRestoreSnapshot() async {
    final doc = await _read();
    if (doc == null || doc.sessionMaps.isEmpty) return null;

    final sessions = doc.sessionMaps
        .map((m) => AiSessionModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();

    var sid = doc.currentSessionId?.trim();
    if (sid == null || sid.isEmpty || !sessions.any((s) => s.id == sid)) {
      sid = sessions.first.id;
    }

    final rawMsgs = doc.messagesBySessionId[sid] ?? const [];
    final messages = rawMsgs
        .map((m) => AiMessageModel.fromJson(Map<String, dynamic>.from(m), fallbackSessionId: sid))
        .toList();

    final pag = doc.paginationBySessionId[sid] ?? const _Pagination(hasMore: false);
    return AiChatRestoreSnapshot(
      sessions: sessions,
      currentSessionId: sid,
      messages: messages,
      hasMore: pag.hasMore,
      nextBefore: pag.nextBefore,
    );
  }

  Future<AiCachedThread?> loadThread(String sessionId) async {
    final sid = sessionId.trim();
    if (sid.isEmpty) return null;
    final doc = await _read();
    if (doc == null) return null;
    final rawMsgs = doc.messagesBySessionId[sid];
    if (rawMsgs == null || rawMsgs.isEmpty) return null;
    final messages = rawMsgs
        .map((m) => AiMessageModel.fromJson(Map<String, dynamic>.from(m), fallbackSessionId: sid))
        .toList();
    final pag = doc.paginationBySessionId[sid] ?? const _Pagination(hasMore: false);
    return AiCachedThread(
      messages: messages,
      hasMore: pag.hasMore,
      nextBefore: pag.nextBefore,
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}

class AiChatRestoreSnapshot {
  const AiChatRestoreSnapshot({
    required this.sessions,
    required this.currentSessionId,
    required this.messages,
    required this.hasMore,
    this.nextBefore,
  });

  final List<AiSessionModel> sessions;
  final String currentSessionId;
  final List<AiMessageModel> messages;
  final bool hasMore;
  final String? nextBefore;
}

class AiCachedThread {
  const AiCachedThread({
    required this.messages,
    required this.hasMore,
    this.nextBefore,
  });

  final List<AiMessageModel> messages;
  final bool hasMore;
  final String? nextBefore;
}

class _Pagination {
  const _Pagination({required this.hasMore, this.nextBefore});

  final bool hasMore;
  final String? nextBefore;

  Map<String, dynamic> toJson() => {
        'hasMore': hasMore,
        if (nextBefore != null) 'nextBefore': nextBefore,
      };

  static _Pagination fromJson(Map<String, dynamic> json) {
    return _Pagination(
      hasMore: json['hasMore'] == true,
      nextBefore: json['nextBefore']?.toString(),
    );
  }
}

class _CacheDoc {
  _CacheDoc({
    required this.sessionMaps,
    required this.currentSessionId,
    required this.messagesBySessionId,
    required this.paginationBySessionId,
  });

  List<Map<String, dynamic>> sessionMaps;
  String? currentSessionId;
  Map<String, List<Map<String, dynamic>>> messagesBySessionId;
  Map<String, _Pagination> paginationBySessionId;

  factory _CacheDoc.empty() => _CacheDoc(
        sessionMaps: [],
        currentSessionId: null,
        messagesBySessionId: {},
        paginationBySessionId: {},
      );

  Map<String, dynamic> toJson() => {
        'version': 1,
        'currentSessionId': currentSessionId,
        'sessions': sessionMaps,
        'messagesBySessionId': messagesBySessionId.map(
          (k, v) => MapEntry(k, v),
        ),
        'paginationBySessionId': paginationBySessionId.map(
          (k, v) => MapEntry(k, v.toJson()),
        ),
      };

  static _CacheDoc fromJson(Map<String, dynamic> json) {
    final sessionsRaw = json['sessions'];
    final sessions = <Map<String, dynamic>>[];
    if (sessionsRaw is List) {
      for (final e in sessionsRaw) {
        if (e is Map) sessions.add(Map<String, dynamic>.from(e));
      }
    }

    final msgRaw = json['messagesBySessionId'];
    final messagesBySid = <String, List<Map<String, dynamic>>>{};
    if (msgRaw is Map) {
      msgRaw.forEach((key, value) {
        if (key is! String || value is! List) return;
        final list = <Map<String, dynamic>>[];
        for (final item in value) {
          if (item is Map) list.add(Map<String, dynamic>.from(item));
        }
        messagesBySid[key] = list;
      });
    }

    final pagRaw = json['paginationBySessionId'];
    final pagBySid = <String, _Pagination>{};
    if (pagRaw is Map) {
      pagRaw.forEach((key, value) {
        if (key is! String || value is! Map) return;
        pagBySid[key] = _Pagination.fromJson(Map<String, dynamic>.from(value));
      });
    }

    return _CacheDoc(
      sessionMaps: sessions,
      currentSessionId: json['currentSessionId']?.toString(),
      messagesBySessionId: messagesBySid,
      paginationBySessionId: pagBySid,
    );
  }
}

Map<String, dynamic> _sessionToMap(AiSessionModel s) => {
      'id': s.id,
      'title': s.title,
      if (s.vehicleId != null) 'vehicle_id': s.vehicleId,
      if (s.vehicleLabel != null) 'vehicle_label': s.vehicleLabel,
      if (s.lastMessagePreview != null) 'last_message_preview': s.lastMessagePreview,
      if (s.messageCount != null) 'message_count': s.messageCount,
      'updated_at': s.updatedAt.toIso8601String(),
      if (s.createdAt != null) 'created_at': s.createdAt!.toIso8601String(),
    };

Map<String, dynamic> _messageToMap(AiMessageModel m) => {
      'id': m.id,
      'session_id': m.sessionId,
      'role': m.role,
      'content': m.content,
      'created_at': m.createdAt.toIso8601String(),
    };

List<Map<String, dynamic>> _trimMessages(List<Map<String, dynamic>> list) {
  if (list.length <= AiChatLocalCache._maxMessagesPerSession) return list;
  return list.sublist(list.length - AiChatLocalCache._maxMessagesPerSession);
}
