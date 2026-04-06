library;

import 'package:equatable/equatable.dart';

class DriverNotification extends Equatable {
  const DriverNotification({
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
  /// Maintenance upcoming / reminder id when the API sends it (for deep-linking).
  final String? upcomingId;

  DriverNotification copyWith({
    String? id,
    String? title,
    String? body,
    bool? read,
    DateTime? createdAt,
    String? upcomingId,
  }) {
    return DriverNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      upcomingId: upcomingId ?? this.upcomingId,
    );
  }

  @override
  List<Object?> get props => [id, title, body, read, createdAt, upcomingId];
}

