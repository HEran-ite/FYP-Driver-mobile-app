library;

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/usecases/list_notifications_usecase.dart';
import '../../application/usecases/mark_notification_read_usecase.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    required ListNotificationsUseCase list,
    required MarkNotificationReadUseCase markRead,
  })  : _list = list,
        _markRead = markRead,
        super(const NotificationsState()) {
    on<NotificationsLoadRequested>(_onLoad);
    on<NotificationMarkReadRequested>(_onMarkRead);
  }

  final ListNotificationsUseCase _list;
  final MarkNotificationReadUseCase _markRead;

  Future<void> _onLoad(NotificationsLoadRequested event, Emitter<NotificationsState> emit) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final items = await _list();
      emit(state.copyWith(loading: false, items: items));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _message(e)));
    }
  }

  Future<void> _onMarkRead(NotificationMarkReadRequested event, Emitter<NotificationsState> emit) async {
    // Optimistic update.
    final current = state.items;
    final updated = current
        .map((n) => n.id == event.id ? n.copyWith(read: true) : n)
        .toList();
    emit(state.copyWith(items: updated));
    try {
      await _markRead(event.id);
    } catch (_) {
      // Revert on failure.
      emit(state.copyWith(items: current));
    }
  }

  String _message(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['error'] != null) return data['error'].toString();
      final code = e.response?.statusCode;
      if (code != null) return 'Request failed ($code)';
      return e.message?.toString() ?? 'Request failed';
    }
    return e.toString();
  }
}

