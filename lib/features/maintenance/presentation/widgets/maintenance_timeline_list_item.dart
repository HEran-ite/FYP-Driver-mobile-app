library;

import 'package:flutter/material.dart';

import '../../../vehicles/domain/entities/vehicle.dart';
import '../models/maintenance_timeline_entry.dart';
import 'maintenance_timeline_read_only_card.dart';

/// Read-only timeline row for the History tab (status only, no actions).
class MaintenanceTimelineListItem extends StatelessWidget {
  const MaintenanceTimelineListItem({
    super.key,
    required this.entry,
    required this.vehicles,
  });

  final MaintenanceTimelineEntry entry;
  final List<Vehicle> vehicles;

  @override
  Widget build(BuildContext context) {
    return MaintenanceTimelineReadOnlyCard(
      entry: entry,
      vehicles: vehicles,
    );
  }
}
