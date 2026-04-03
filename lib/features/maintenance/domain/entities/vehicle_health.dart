library;

import 'package:equatable/equatable.dart';

/// One subsystem score (e.g. Engine, Brakes) from GET /driver/maintenance/health/:vehicleId.
class VehicleHealthComponent extends Equatable {
  const VehicleHealthComponent({required this.label, required this.percent});

  final String label;
  final int percent;

  @override
  List<Object?> get props => [label, percent];
}

/// Aggregated car health for a vehicle.
class VehicleHealth extends Equatable {
  const VehicleHealth({
    required this.overallPercent,
    this.components = const [],
    this.summary,
  });

  final int overallPercent;
  final List<VehicleHealthComponent> components;
  final String? summary;

  @override
  List<Object?> get props => [overallPercent, components, summary];
}
