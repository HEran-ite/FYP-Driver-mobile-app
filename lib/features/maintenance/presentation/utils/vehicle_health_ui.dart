library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/vehicle_health.dart';

Color vehicleHealthColorForPercent(int pct) {
  if (pct >= 75) return AppColors.success;
  if (pct >= 45) return AppColors.pending;
  return AppColors.danger;
}

/// Dedupes by label, sorts by health **ascending** (lowest first), then label.
/// [maxItems] keeps the lowest [maxItems] by percent (after sort).
List<VehicleHealthComponent> orderedHealthComponents(
  List<VehicleHealthComponent> list, {
  int? maxItems,
}) {
  final byLabel = <String, VehicleHealthComponent>{};
  for (final c in list) {
    final k = c.label.toLowerCase();
    byLabel.putIfAbsent(k, () => c);
  }
  final sorted = byLabel.values.toList()
    ..sort((a, b) {
      final cmp = a.percent.compareTo(b.percent);
      if (cmp != 0) return cmp;
      return a.label.toLowerCase().compareTo(b.label.toLowerCase());
    });
  if (maxItems != null && sorted.length > maxItems) {
    return sorted.take(maxItems).toList();
  }
  return sorted;
}
