library;

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/usecases/create_history_usecase.dart';
import '../../application/usecases/create_upcoming_usecase.dart';
import '../../application/usecases/delete_history_usecase.dart';
import '../../application/usecases/delete_upcoming_usecase.dart';
import '../../application/usecases/list_history_usecase.dart';
import '../../application/usecases/list_upcoming_usecase.dart';
import '../../application/usecases/mark_reminder_done_usecase.dart';
import '../../application/usecases/toggle_reminder_usecase.dart';
import '../../application/usecases/update_history_usecase.dart';
import '../../domain/entities/maintenance_history.dart';
import '../../domain/entities/maintenance_upcoming.dart';
import '../models/maintenance_timeline_entry.dart';
import 'maintenance_event.dart';
import 'maintenance_state.dart';

class MaintenanceBloc extends Bloc<MaintenanceEvent, MaintenanceState> {
  MaintenanceBloc({
    required ListUpcomingUseCase listUpcoming,
    required ListHistoryUseCase listHistory,
    required CreateUpcomingUseCase createUpcoming,
    required DeleteUpcomingUseCase deleteUpcoming,
    required DeleteHistoryUseCase deleteHistory,
    required CreateHistoryUseCase createHistory,
    required UpdateHistoryUseCase updateHistory,
    required ToggleReminderUseCase toggleReminder,
    required MarkReminderDoneUseCase markReminderDone,
  })  : _listUpcoming = listUpcoming,
        _listHistory = listHistory,
        _createUpcoming = createUpcoming,
        _deleteUpcoming = deleteUpcoming,
        _deleteHistory = deleteHistory,
        _createHistory = createHistory,
        _updateHistory = updateHistory,
        _toggleReminder = toggleReminder,
        _markReminderDone = markReminderDone,
        super(const MaintenanceState()) {
    on<MaintenanceLoadRequested>(_onLoad);
    on<MaintenanceUpcomingCreateRequested>(_onCreateUpcoming);
    on<MaintenanceUpcomingDeleteRequested>(_onDeleteUpcoming);
    on<MaintenanceHistoryDeleteRequested>(_onDeleteHistory);
    on<MaintenanceHistoryCreateRequested>(_onCreateHistory);
    on<MaintenanceHistoryUpdateRequested>(_onUpdateHistory);
    on<MaintenanceToggleReminderRequested>(_onToggleReminder);
    on<MaintenanceMarkDoneRequested>(_onMarkDone);
  }

  final ListUpcomingUseCase _listUpcoming;
  final ListHistoryUseCase _listHistory;
  final CreateUpcomingUseCase _createUpcoming;
  final DeleteUpcomingUseCase _deleteUpcoming;
  final DeleteHistoryUseCase _deleteHistory;
  final CreateHistoryUseCase _createHistory;
  final UpdateHistoryUseCase _updateHistory;
  final ToggleReminderUseCase _toggleReminder;
  final MarkReminderDoneUseCase _markReminderDone;

  Future<void> _onLoad(MaintenanceLoadRequested event, Emitter<MaintenanceState> emit) async {
    emit(state.copyWith(
      loading: true,
      clearError: true,
      filterVehicleId: event.vehicleId,
      hasFilterVehicleId: true,
    ));
    try {
      final upcoming = await _listUpcoming(vehicleId: event.vehicleId, includeCompleted: true);
      final history = await _listHistory();
      final filteredHistory = _historyForVehicle(history, event.vehicleId);
      emit(state.copyWith(
        loading: false,
        upcoming: upcoming,
        history: filteredHistory,
        filterVehicleId: event.vehicleId,
        hasFilterVehicleId: true,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _message(e)));
    }
  }

  List<MaintenanceHistory> _historyForVehicle(List<MaintenanceHistory> all, String? vehicleId) {
    if (vehicleId == null || vehicleId.isEmpty) return all;
    return all.where((h) => h.vehicleId == null || h.vehicleId == vehicleId).toList();
  }

  Future<void> _onCreateUpcoming(
    MaintenanceUpcomingCreateRequested event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      await _createUpcoming(
        vehicleId: event.vehicleId,
        presetCategory: event.presetCategory,
        customServiceName: event.customServiceName,
        scheduledAt: event.scheduledAt,
        estimatedCostMin: event.estimatedCostMin,
        estimatedCostMax: event.estimatedCostMax,
        notes: event.notes,
      );
      final upcoming = await _listUpcoming(vehicleId: state.filterVehicleId, includeCompleted: true);
      final history = await _listHistory();
      emit(state.copyWith(
        loading: false,
        upcoming: upcoming,
        history: _historyForVehicle(history, state.filterVehicleId),
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _message(e)));
    }
  }

  Future<void> _onDeleteUpcoming(
    MaintenanceUpcomingDeleteRequested event,
    Emitter<MaintenanceState> emit,
  ) async {
    MaintenanceUpcoming? snapshot;
    for (final u in state.upcoming) {
      if (u.id == event.id) {
        snapshot = u;
        break;
      }
    }
    emit(state.copyWith(loading: true, clearError: true));
    try {
      await _deleteUpcoming(event.id);
      if (snapshot != null) {
        final day = DateTime(snapshot.scheduledAt.year, snapshot.scheduledAt.month, snapshot.scheduledAt.day);
        try {
          await _createHistory(
            vehicleId: snapshot.vehicleId,
            serviceName: '$kDeletedReminderHistoryTitlePrefix${snapshot.title}',
            serviceDate: day,
          );
        } catch (_) {}
      }
      final upcoming = await _listUpcoming(vehicleId: state.filterVehicleId, includeCompleted: true);
      final history = await _listHistory();
      emit(state.copyWith(
        loading: false,
        upcoming: upcoming,
        history: _historyForVehicle(history, state.filterVehicleId),
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _message(e)));
    }
  }

  Future<void> _onDeleteHistory(
    MaintenanceHistoryDeleteRequested event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      await _deleteHistory(event.id);
      final history = await _listHistory();
      emit(state.copyWith(
        loading: false,
        history: _historyForVehicle(history, state.filterVehicleId),
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _message(e)));
    }
  }

  Future<void> _onCreateHistory(
    MaintenanceHistoryCreateRequested event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      await _createHistory(
        vehicleId: event.vehicleId,
        serviceName: event.serviceName,
        garageName: event.garageName,
        serviceDate: event.serviceDate,
        cost: event.cost,
        notes: event.notes,
      );
      final history = await _listHistory();
      emit(state.copyWith(
        loading: false,
        history: _historyForVehicle(history, state.filterVehicleId),
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _message(e)));
    }
  }

  Future<void> _onUpdateHistory(
    MaintenanceHistoryUpdateRequested event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      await _updateHistory(
        id: event.id,
        vehicleId: event.vehicleId,
        serviceName: event.serviceName,
        garageName: event.garageName,
        serviceDate: event.serviceDate,
        cost: event.cost,
        notes: event.notes,
      );
      final history = await _listHistory();
      emit(state.copyWith(
        loading: false,
        history: _historyForVehicle(history, state.filterVehicleId),
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _message(e)));
    }
  }

  Future<void> _onToggleReminder(
    MaintenanceToggleReminderRequested event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final updatedItem = await _toggleReminder(event.id);
      final updated = state.upcoming.map((u) {
        if (u.id != event.id) return u;
        return u.mergeWith(updatedItem);
      }).toList();
      emit(state.copyWith(loading: false, upcoming: updated));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _message(e)));
    }
  }

  Future<void> _onMarkDone(
    MaintenanceMarkDoneRequested event,
    Emitter<MaintenanceState> emit,
  ) async {
    MaintenanceUpcoming? reminder;
    for (final u in state.upcoming) {
      if (u.id == event.id) {
        reminder = u;
        break;
      }
    }
    emit(state.copyWith(loading: true, clearError: true));
    try {
      await _markReminderDone(event.id);
      // Backend does not create a history row when a reminder is completed; mirror it here so History fills in.
      if (reminder != null) {
        final now = DateTime.now();
        final completedDay = DateTime(now.year, now.month, now.day);
        try {
          await _createHistory(
            vehicleId: reminder.vehicleId,
            serviceName: reminder.title,
            serviceDate: completedDay,
            notes: 'Completed from scheduled reminder',
          );
        } catch (_) {
          // Reminder is already done; history is best-effort.
        }
      }
      final upcoming = await _listUpcoming(vehicleId: state.filterVehicleId, includeCompleted: true);
      final history = await _listHistory();
      emit(state.copyWith(
        loading: false,
        upcoming: upcoming,
        history: _historyForVehicle(history, state.filterVehicleId),
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _message(e)));
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
