library;

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/usecases/create_upcoming_usecase.dart';
import '../../application/usecases/delete_history_usecase.dart';
import '../../application/usecases/delete_upcoming_usecase.dart';
import '../../application/usecases/list_history_usecase.dart';
import '../../application/usecases/list_upcoming_usecase.dart';
import '../../application/usecases/toggle_reminder_usecase.dart';
import '../../domain/entities/maintenance_history.dart';
import '../../domain/entities/maintenance_upcoming.dart';
import 'maintenance_event.dart';
import 'maintenance_state.dart';

class MaintenanceBloc extends Bloc<MaintenanceEvent, MaintenanceState> {
  MaintenanceBloc({
    required ListUpcomingUseCase listUpcoming,
    required ListHistoryUseCase listHistory,
    required CreateUpcomingUseCase createUpcoming,
    required DeleteUpcomingUseCase deleteUpcoming,
    required DeleteHistoryUseCase deleteHistory,
    required ToggleReminderUseCase toggleReminder,
  })  : _listUpcoming = listUpcoming,
        _listHistory = listHistory,
        _createUpcoming = createUpcoming,
        _deleteUpcoming = deleteUpcoming,
        _deleteHistory = deleteHistory,
        _toggleReminder = toggleReminder,
        super(const MaintenanceState()) {
    on<MaintenanceLoadRequested>(_onLoad);
    on<MaintenanceUpcomingCreateRequested>(_onCreateUpcoming);
    on<MaintenanceUpcomingDeleteRequested>(_onDeleteUpcoming);
    on<MaintenanceHistoryDeleteRequested>(_onDeleteHistory);
    on<MaintenanceToggleReminderRequested>(_onToggleReminder);
  }

  final ListUpcomingUseCase _listUpcoming;
  final ListHistoryUseCase _listHistory;
  final CreateUpcomingUseCase _createUpcoming;
  final DeleteUpcomingUseCase _deleteUpcoming;
  final DeleteHistoryUseCase _deleteHistory;
  final ToggleReminderUseCase _toggleReminder;

  Future<void> _onLoad(MaintenanceLoadRequested event, Emitter<MaintenanceState> emit) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final upcoming = await _listUpcoming();
      final history = await _listHistory();
      emit(state.copyWith(
        loading: false,
        upcoming: upcoming,
        history: history,
        usingMockData: false,
      ));
    } catch (e) {
      // If backend isn't implemented yet, keep UI usable with mock data.
      if (e is DioException && e.response?.statusCode == 404) {
        emit(state.copyWith(
          loading: false,
          upcoming: _mockUpcoming(),
          history: _mockHistory(),
          usingMockData: true,
        ));
        return;
      }
      emit(state.copyWith(loading: false, error: _message(e)));
    }
  }

  Future<void> _onCreateUpcoming(
    MaintenanceUpcomingCreateRequested event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final created = await _createUpcoming(
        title: event.title,
        scheduledAt: event.scheduledAt,
        estimatedCost: event.estimatedCost,
        vehicleId: event.vehicleId,
      );
      final updated = [created, ...state.upcoming]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      emit(state.copyWith(loading: false, upcoming: updated));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _message(e)));
    }
  }

  Future<void> _onDeleteUpcoming(
    MaintenanceUpcomingDeleteRequested event,
    Emitter<MaintenanceState> emit,
  ) async {
    final current = state;
    emit(state.copyWith(loading: true, clearError: true));
    try {
      if (!state.usingMockData) await _deleteUpcoming(event.id);
      emit(state.copyWith(
        loading: false,
        upcoming: current.upcoming.where((x) => x.id != event.id).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _message(e)));
    }
  }

  Future<void> _onDeleteHistory(
    MaintenanceHistoryDeleteRequested event,
    Emitter<MaintenanceState> emit,
  ) async {
    final current = state;
    emit(state.copyWith(loading: true, clearError: true));
    try {
      if (!state.usingMockData) await _deleteHistory(event.id);
      emit(state.copyWith(
        loading: false,
        history: current.history.where((x) => x.id != event.id).toList(),
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
      if (state.usingMockData) {
        final updated = state.upcoming
            .map((u) => u.id == event.id
                ? MaintenanceUpcoming(
                    id: u.id,
                    title: u.title,
                    scheduledAt: u.scheduledAt,
                    estimatedCost: u.estimatedCost,
                    reminderEnabled: !u.reminderEnabled,
                    garageName: u.garageName,
                  )
                : u)
            .toList();
        emit(state.copyWith(loading: false, upcoming: updated));
        return;
      }
      final updatedItem = await _toggleReminder(event.id);
      final updated = state.upcoming.map((u) => u.id == event.id ? updatedItem : u).toList();
      emit(state.copyWith(loading: false, upcoming: updated));
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

  List<MaintenanceUpcoming> _mockUpcoming() {
    final now = DateTime.now();
    return [
      MaintenanceUpcoming(
        id: 'mock-up-1',
        title: 'Tire Check',
        scheduledAt: DateTime(now.year, now.month, now.day).add(const Duration(days: 2)),
        estimatedCost: r'Est. $30-50',
        reminderEnabled: true,
        vehicleId: 'mock-veh-1',
      ),
      MaintenanceUpcoming(
        id: 'mock-up-2',
        title: 'Brake Service',
        scheduledAt: DateTime(now.year, now.month, now.day).add(const Duration(days: 13)),
        estimatedCost: r'Est. $100-150',
        reminderEnabled: false,
        vehicleId: 'mock-veh-1',
      ),
    ];
  }

  List<MaintenanceHistory> _mockHistory() {
    final now = DateTime.now();
    return [
      MaintenanceHistory(
        id: 'mock-h-1',
        title: 'Oil Change',
        garageName: 'AutoCare Center',
        date: now.subtract(const Duration(days: 30)),
        amount: 45,
      ),
      MaintenanceHistory(
        id: 'mock-h-2',
        title: 'Tire Rotation',
        garageName: 'QuickFix Garage',
        date: now.subtract(const Duration(days: 42)),
        amount: 35,
      ),
    ];
  }
}

