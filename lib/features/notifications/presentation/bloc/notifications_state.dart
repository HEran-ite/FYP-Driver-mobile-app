library;

import 'package:equatable/equatable.dart';

import '../../domain/entities/driver_notification.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.loading = false,
    this.items = const [],
    this.error,
  });

  final bool loading;
  final List<DriverNotification> items;
  final String? error;

  NotificationsState copyWith({
    bool? loading,
    List<DriverNotification>? items,
    String? error,
    bool clearError = false,
  }) {
    return NotificationsState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
    );
  }

  int get unreadCount => items.where((n) => !n.read).length;

  @override
  List<Object?> get props => [loading, items, error];
}
