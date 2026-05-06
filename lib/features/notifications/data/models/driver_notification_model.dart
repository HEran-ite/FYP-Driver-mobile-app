library;

import '../../domain/entities/driver_notification.dart';

class DriverNotificationModel {
  const DriverNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.upcomingId,
  });

  final String id;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;
  final String? upcomingId;

  factory DriverNotificationModel.fromJson(Map<String, dynamic>? json) {
    final m = json ?? const <String, dynamic>{};
    DateTime parseDate(dynamic v) {
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    String? upcomingIdFrom(Map<dynamic, dynamic> map) {
      final keys = [
        'upcomingId',
        'reminderId',
        'maintenanceUpcomingId',
        'upcoming_id',
        'reminder_id',
      ];
      for (final k in keys) {
        final v = map[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString().trim();
        }
      }
      return null;
    }

    String? nestedUpcomingId() {
      final direct = upcomingIdFrom(m);
      if (direct != null) return direct;
      final meta = m['metadata'];
      if (meta is Map) {
        final u = upcomingIdFrom(Map<dynamic, dynamic>.from(meta));
        if (u != null) return u;
      }
      final data = m['data'];
      if (data is Map) {
        final u = upcomingIdFrom(Map<dynamic, dynamic>.from(data));
        if (u != null) return u;
      }
      return null;
    }

    return DriverNotificationModel(
      id: m['id']?.toString() ?? '',
      title: m['title']?.toString() ?? 'Notification',
      body: m['body']?.toString() ?? m['message']?.toString() ?? '',
      read: m['read'] == true,
      createdAt: parseDate(m['createdAt'] ?? m['created_at']),
      upcomingId: nestedUpcomingId(),
    );
  }

  DriverNotification toEntity() => DriverNotification(
    id: id,
    title: title,
    body: body,
    read: read,
    createdAt: createdAt,
    upcomingId: upcomingId,
  );
}
