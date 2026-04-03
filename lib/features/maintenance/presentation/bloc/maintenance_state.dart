library;

import 'package:equatable/equatable.dart';

import '../../domain/entities/maintenance_history.dart';
import '../../domain/entities/maintenance_upcoming.dart';

class MaintenanceState extends Equatable {
  const MaintenanceState({
    this.loading = false,
    this.upcoming = const [],
    this.history = const [],
    this.error,
    this.filterVehicleId,
  });

  final bool loading;
  final List<MaintenanceUpcoming> upcoming;
  final List<MaintenanceHistory> history;
  final String? error;
  final String? filterVehicleId;

  MaintenanceState copyWith({
    bool? loading,
    List<MaintenanceUpcoming>? upcoming,
    List<MaintenanceHistory>? history,
    String? error,
    bool clearError = false,
    String? filterVehicleId,
    bool hasFilterVehicleId = false,
  }) {
    return MaintenanceState(
      loading: loading ?? this.loading,
      upcoming: upcoming ?? this.upcoming,
      history: history ?? this.history,
      error: clearError ? null : (error ?? this.error),
      filterVehicleId: hasFilterVehicleId ? filterVehicleId : this.filterVehicleId,
    );
  }

  @override
  List<Object?> get props => [loading, upcoming, history, error, filterVehicleId];
}
