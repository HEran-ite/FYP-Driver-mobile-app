library;

import '../../domain/entities/driver_notification.dart';

class DriverNotificationModel {
  const DriverNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;

  factory DriverNotificationModel.fromJson(Map<String, dynamic>? json) {
    final m = json ?? const <String, dynamic>{};
    DateTime parseDate(dynamic v) {
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return DriverNotificationModel(
      id: m['id']?.toString() ?? '',
      title: m['title']?.toString() ?? 'Notification',
      body: m['body']?.toString() ?? '',
      read: m['read'] == true,
      createdAt: parseDate(m['createdAt']),
    );
  }

  DriverNotification toEntity() => DriverNotification(
        id: id,
        title: title,
        body: body,
        read: read,
        createdAt: createdAt,
      );
}

