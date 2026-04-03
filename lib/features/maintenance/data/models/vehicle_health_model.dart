library;

import '../../domain/entities/vehicle_health.dart';

class VehicleHealthModel {
  const VehicleHealthModel({
    required this.overallPercent,
    this.components = const [],
    this.summary,
  });

  final int overallPercent;
  final List<VehicleHealthComponentModel> components;
  final String? summary;

  VehicleHealth toEntity() => VehicleHealth(
        overallPercent: overallPercent,
        components: components.map((c) => c.toEntity()).toList(),
        summary: summary,
      );
}

class VehicleHealthComponentModel {
  const VehicleHealthComponentModel({required this.label, required this.percent});

  final String label;
  final int percent;

  VehicleHealthComponent toEntity() =>
      VehicleHealthComponent(label: label, percent: percent.clamp(0, 100));
}

/// Parses driver-garage-backend GET /driver/maintenance/health/:vehicleId:
/// `{ vehicleId, health: { ENGINE, BRAKES, ..., custom: [...] }, overallHealth }`
/// See: driver-garage-backend `maintenance-health.types.ts` / `maintenance.controller.ts`.
class VehicleHealthModelParser {
  static VehicleHealthModel fromJson(dynamic raw) {
    final m = _unwrap(raw);
    if (_isDriverGarageHealthEnvelope(m)) {
      return _fromDriverGarageEnvelope(m);
    }
    return _fromLegacyFlexibleJson(m);
  }

  static bool _isDriverGarageHealthEnvelope(Map<String, dynamic> m) {
    if (m.containsKey('overallHealth')) return true;
    final h = m['health'];
    if (h is Map && h['ENGINE'] != null) return true;
    if (h is Map && h['custom'] is List) return true;
    return false;
  }

  /// Same order as backend FIXED_KEYS in maintenance-health.helpers.ts
  static const List<String> _backendFixedKeyOrder = [
    'ENGINE',
    'BRAKES',
    'TIRES',
    'BATTERY',
    'COOLANT',
    'TRANSMISSION',
    'AIR_FILTER',
    'WIPERS_LIGHTS',
  ];

  static const Map<String, String> _backendFixedLabels = {
    'ENGINE': 'Engine',
    'BRAKES': 'Brakes',
    'TIRES': 'Tires',
    'BATTERY': 'Battery',
    'COOLANT': 'Coolant',
    'TRANSMISSION': 'Transmission',
    'AIR_FILTER': 'Air filter',
    'WIPERS_LIGHTS': 'Wipers & lights',
  };

  static VehicleHealthModel _fromDriverGarageEnvelope(Map<String, dynamic> m) {
    final components = <VehicleHealthComponentModel>[];

    final healthRaw = m['health'];
    if (healthRaw is Map) {
      final h = Map<String, dynamic>.from(healthRaw);
      for (final key in _backendFixedKeyOrder) {
        if (!h.containsKey(key)) continue;
        final pct = _parseInt(h[key]);
        if (pct != null) {
          final label = _backendFixedLabels[key] ?? _titleCaseLabel(key.replaceAll('_', ' '));
          components.add(VehicleHealthComponentModel(label: label, percent: pct));
        }
      }

      final custom = h['custom'];
      if (custom is List) {
        for (final e in custom) {
          if (e is! Map) continue;
          final row = Map<String, dynamic>.from(e);
          final id = row['id']?.toString();
          final label = row['label']?.toString().trim();
          final pct = _parseInt(row['percentage']);
          if (label != null && label.isNotEmpty && pct != null) {
            components.add(VehicleHealthComponentModel(label: label, percent: pct));
          } else if (id != null && id.isNotEmpty && pct != null) {
            components.add(VehicleHealthComponentModel(label: id, percent: pct));
          }
        }
      }
    }

    var overall = _parseInt(m['overallHealth']);
    if (overall == null) {
      overall = _firstInt(m, const [
        'overall',
        'overallPercent',
        'overallCarHealth',
        'carHealth',
        'score',
        'total',
      ]);
    }
    if (overall == null && components.isNotEmpty) {
      final sum = components.fold<int>(0, (a, c) => a + c.percent);
      overall = (sum / components.length).round();
    }
    overall ??= 0;
    overall = overall.clamp(0, 100);

    final summary = _firstString(m, const ['summary', 'message', 'note', 'description']);

    return VehicleHealthModel(
      overallPercent: overall,
      components: components,
      summary: summary,
    );
  }

  static VehicleHealthModel _fromLegacyFlexibleJson(Map<String, dynamic> m) {
    final components = <VehicleHealthComponentModel>[];

    void ingestMap(Map<String, dynamic> map) {
      _parseComponentList(map['components'], components);
      _parseComponentList(map['subsystems'], components);
      _parseComponentList(map['systems'], components);
      _parseComponentList(map['subsystemScores'], components);
      _parseComponentList(map['items'], components);
      _parseBreakdownMap(map['breakdown'], components);
      _parseComponentList(map['breakdown'], components);
      _parseBreakdownMap(map['subsystemScores'], components);
      _parseNamedScores(map, components);
    }

    ingestMap(m);

    final healthNested = m['health'];
    if (healthNested is Map) {
      final hm = Map<String, dynamic>.from(healthNested);
      if (!_isDriverGarageHealthShape(hm)) {
        ingestMap(hm);
      }
    }
    final vehicleHealth = m['vehicleHealth'];
    if (vehicleHealth is Map) {
      ingestMap(Map<String, dynamic>.from(vehicleHealth));
    }

    var overall = _firstInt(m, const [
      'overall',
      'overallHealth',
      'overallPercent',
      'overallCarHealth',
      'carHealth',
      'score',
      'total',
    ]);

    if (overall == null && components.isNotEmpty) {
      final sum = components.fold<int>(0, (a, c) => a + c.percent);
      overall = (sum / components.length).round();
    }

    overall ??= 0;
    overall = overall.clamp(0, 100);

    final summary = _firstString(m, const ['summary', 'message', 'note', 'description']);

    final deduped = <VehicleHealthComponentModel>[];
    final seen = <String>{};
    for (final c in components) {
      final k = c.label.toLowerCase();
      if (seen.add(k)) deduped.add(c);
    }

    return VehicleHealthModel(
      overallPercent: overall,
      components: deduped,
      summary: summary,
    );
  }

  static bool _isDriverGarageHealthShape(Map<String, dynamic> h) {
    return h.containsKey('ENGINE');
  }

  static Map<String, dynamic> _unwrap(dynamic raw) {
    if (raw is! Map) return {};
    final top = Map<String, dynamic>.from(raw);
    for (final key in ['data', 'result', 'payload', 'body']) {
      final inner = top[key];
      if (inner is Map) {
        return Map<String, dynamic>.from(inner);
      }
    }
    return top;
  }

  static void _parseBreakdownMap(dynamic map, List<VehicleHealthComponentModel> out) {
    if (map is! Map) return;
    final m = Map<String, dynamic>.from(map);
    m.forEach((key, value) {
      final k = key.toString();
      if (k == 'overall' || k == 'summary' || k == 'total' || k == 'message' || k == 'custom') return;
      final pct = _parseScoreValue(value);
      if (pct == null) return;
      var label = k.replaceAll(RegExp(r'Health$'), '').replaceAll(RegExp(r'Score$'), '');
      label = _titleCaseLabel(label.replaceAll('_', ' '));
      if (label.isEmpty) return;
      out.add(VehicleHealthComponentModel(label: label, percent: pct));
    });
  }

  static int? _parseScoreValue(dynamic value) {
    final direct = _parseInt(value);
    if (direct != null) return direct;
    if (value is Map) {
      final inner = Map<String, dynamic>.from(value);
      return _firstInt(inner, const [
        'percent',
        'percentage',
        'score',
        'health',
        'value',
        'overall',
      ]);
    }
    return null;
  }

  static void _parseComponentList(dynamic list, List<VehicleHealthComponentModel> out) {
    if (list is! List) return;
    for (final e in list) {
      if (e is! Map) continue;
      final map = Map<String, dynamic>.from(e);
      final label = _firstString(map, const [
        'label',
        'name',
        'title',
        'id',
        'key',
        'component',
        'type',
        'system',
        'subsystem',
        'category',
      ]);
      var pct = _firstInt(map, const [
        'percent',
        'percentage',
        'value',
        'score',
        'health',
      ]);
      pct ??= map['value'] is Map ? _parseScoreValue(map['value']) : null;
      if (label != null && label.isNotEmpty && pct != null) {
        out.add(VehicleHealthComponentModel(label: _titleCaseLabel(label), percent: pct));
      }
    }
  }

  static const _flatKeys = [
    ('engine', 'Engine'),
    ('brakes', 'Brakes'),
    ('tires', 'Tires'),
    ('battery', 'Battery'),
    ('transmission', 'Transmission'),
    ('suspension', 'Suspension'),
    ('cooling', 'Cooling'),
    ('electrical', 'Electrical'),
    ('exhaust', 'Exhaust'),
    ('engineHealth', 'Engine'),
    ('brakeHealth', 'Brakes'),
    ('tireHealth', 'Tires'),
    ('batteryHealth', 'Battery'),
  ];

  static void _parseNamedScores(Map<String, dynamic> m, List<VehicleHealthComponentModel> out) {
    final existing = out.map((c) => c.label.toLowerCase()).toSet();
    for (final entry in _flatKeys) {
      final key = entry.$1;
      final label = entry.$2;
      if (existing.contains(label.toLowerCase())) continue;
      final v = m[key];
      if (v == null) continue;
      final pct = _parseScoreValue(v);
      if (pct == null) continue;
      out.add(VehicleHealthComponentModel(label: label, percent: pct));
      existing.add(label.toLowerCase());
    }
  }

  static int? _firstInt(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      if (!m.containsKey(k)) continue;
      final v = _parseInt(m[k]);
      if (v != null) return v;
    }
    return null;
  }

  static String? _firstString(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
    }
    return null;
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v.clamp(0, 100);
    if (v is num) return v.round().clamp(0, 100);
    if (v is String) return int.tryParse(v.trim())?.clamp(0, 100);
    return null;
  }

  static String _titleCaseLabel(String s) {
    final t = s.replaceAll('_', ' ').trim();
    if (t.isEmpty) return s;
    return t[0].toUpperCase() + t.substring(1).toLowerCase();
  }
}
