library;

import 'package:equatable/equatable.dart';

class DriverNotification extends Equatable {
  const DriverNotification({
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

  @override
  List<Object?> get props => [id, title, body, read, createdAt];
}

