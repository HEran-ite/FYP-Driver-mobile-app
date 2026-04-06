library;

import 'package:equatable/equatable.dart';

class MaintenanceCatalogItem extends Equatable {
  const MaintenanceCatalogItem({
    required this.id,
    required this.label,
    required this.description,
    required this.healthComponent,
  });

  final String id;
  final String label;
  final String description;
  final String healthComponent;

  static const String otherId = 'OTHER';

  @override
  List<Object?> get props => [id, label, description, healthComponent];
}

class MaintenanceCatalogRules extends Equatable {
  const MaintenanceCatalogRules({
    this.soonDays,
    this.healthReductionPercent,
    this.displayStatusHelp,
  });

  final int? soonDays;
  final int? healthReductionPercent;
  final String? displayStatusHelp;

  @override
  List<Object?> get props => [soonDays, healthReductionPercent, displayStatusHelp];
}

class MaintenanceCatalog extends Equatable {
  const MaintenanceCatalog({
    required this.presets,
    this.rules,
  });

  final List<MaintenanceCatalogItem> presets;
  final MaintenanceCatalogRules? rules;

  @override
  List<Object?> get props => [presets, rules];
}
