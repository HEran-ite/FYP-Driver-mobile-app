library;

class AiSessionModel {
  const AiSessionModel({
    required this.id,
    required this.title,
    this.vehicleId,
    this.vehicleLabel,
    this.lastMessagePreview,
    this.messageCount,
    required this.updatedAt,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? vehicleId;
  final String? vehicleLabel;
  final String? lastMessagePreview;
  final int? messageCount;
  final DateTime updatedAt;
  final DateTime? createdAt;

  factory AiSessionModel.fromJson(Map<String, dynamic> json) {
    String id =
        _asString(json['id']) ??
        _asString(json['_id']) ??
        _asString(json['sessionId']) ??
        '';
    if (id.isEmpty) {
      id = DateTime.now().microsecondsSinceEpoch.toString();
    }

    final title =
        _asString(json['title']) ??
        _asString(json['name']) ??
        _asString(json['subject']) ??
        'Chat Session';

    final updatedAt =
        _asDateTime(json['updatedAt']) ??
        _asDateTime(json['updated_at']) ??
        _asDateTime(json['lastMessageAt']) ??
        _asDateTime(json['last_message_at']) ??
        DateTime.now();

    final createdAt =
        _asDateTime(json['createdAt']) ?? _asDateTime(json['created_at']);

    return AiSessionModel(
      id: id,
      title: title,
      vehicleId:
          _asString(json['vehicleId']) ??
          _asString(json['vehicle_id']) ??
          _asString(json['carId']),
      vehicleLabel:
          _asString(json['vehicleLabel']) ??
          _asString(json['vehicle_label']) ??
          _asString(json['vehicleName']) ??
          _asString(json['vehicle_name']),
      lastMessagePreview:
          _asString(json['lastMessagePreview']) ??
          _asString(json['last_message_preview']) ??
          _asString(json['lastMessage']) ??
          _asString(json['last_message']),
      messageCount: _asInt(json['messageCount']) ?? _asInt(json['message_count']),
      updatedAt: updatedAt,
      createdAt: createdAt,
    );
  }

  AiSessionModel copyWith({
    String? title,
    String? vehicleId,
    String? vehicleLabel,
    String? lastMessagePreview,
    int? messageCount,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return AiSessionModel(
      id: id,
      title: title ?? this.title,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleLabel: vehicleLabel ?? this.vehicleLabel,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      messageCount: messageCount ?? this.messageCount,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

String? _asString(dynamic v) {
  final s = v?.toString().trim();
  if (s == null || s.isEmpty) return null;
  return s;
}

int? _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.round();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

DateTime? _asDateTime(dynamic v) {
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}
