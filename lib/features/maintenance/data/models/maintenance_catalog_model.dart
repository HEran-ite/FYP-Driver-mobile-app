library;

class MaintenanceCatalogItemModel {
  const MaintenanceCatalogItemModel({
    required this.id,
    required this.label,
    required this.description,
    required this.healthComponent,
  });

  final String id;
  final String label;
  final String description;
  final String healthComponent;

  factory MaintenanceCatalogItemModel.fromJson(Map<String, dynamic>? json) {
    final m = json ?? const <String, dynamic>{};
    return MaintenanceCatalogItemModel(
      id: m['id']?.toString() ?? '',
      label: m['label']?.toString() ?? '',
      description: m['description']?.toString() ?? '',
      healthComponent: m['healthComponent']?.toString() ?? '',
    );
  }
}

class MaintenanceCatalogRulesModel {
  const MaintenanceCatalogRulesModel({
    this.soonDays,
    this.healthReductionPercent,
    this.displayStatusHelp,
  });

  final int? soonDays;
  final int? healthReductionPercent;
  final String? displayStatusHelp;

  factory MaintenanceCatalogRulesModel.fromJson(Map<String, dynamic>? json) {
    final m = json ?? const <String, dynamic>{};
    int? asInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return null;
    }

    return MaintenanceCatalogRulesModel(
      soonDays: asInt(m['soonDays']),
      healthReductionPercent: asInt(m['healthReductionPercent']),
      displayStatusHelp: m['displayStatusHelp']?.toString(),
    );
  }
}

class MaintenanceCatalogResponseModel {
  const MaintenanceCatalogResponseModel({
    required this.presets,
    this.rules,
  });

  final List<MaintenanceCatalogItemModel> presets;
  final MaintenanceCatalogRulesModel? rules;

  factory MaintenanceCatalogResponseModel.fromJson(Map<String, dynamic>? json) {
    final m = json ?? const <String, dynamic>{};
    final raw = m['presets'];
    final list = raw is List ? raw : const <dynamic>[];
    return MaintenanceCatalogResponseModel(
      presets: list
          .map((e) => MaintenanceCatalogItemModel.fromJson(e is Map<String, dynamic> ? e : null))
          .where((p) => p.id.isNotEmpty)
          .toList(),
      rules: m['rules'] is Map<String, dynamic>
          ? MaintenanceCatalogRulesModel.fromJson(m['rules'] as Map<String, dynamic>)
          : null,
    );
  }
}
