library;

import '../../domain/entities/maintenance_history.dart';

class MaintenanceHistoryModel {
  const MaintenanceHistoryModel({
    required this.id,
    required this.title,
    required this.date,
    this.garageName,
    this.amount,
    this.vehicleId,
    this.notes,
  });

  final String id;
  final String title;
  final DateTime date;
  final String? garageName;
  final num? amount;
  final String? vehicleId;
  final String? notes;

  factory MaintenanceHistoryModel.fromJson(Map<String, dynamic>? json) {
    final m = json ?? const <String, dynamic>{};
    DateTime parseDate(dynamic v) {
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    num? parseNum(dynamic v) {
      if (v is num) return v;
      if (v is String) return num.tryParse(v);
      return null;
    }

    return MaintenanceHistoryModel(
      id: m['id']?.toString() ?? m['_id']?.toString() ?? '',
      // Backend (driver-maintenance-yordi): serviceName, serviceDate, cost
      title: m['serviceName']?.toString() ?? m['title']?.toString() ?? m['service']?.toString() ?? 'Maintenance',
      date: parseDate(m['serviceDate'] ?? m['date'] ?? m['completedAt'] ?? m['scheduledAt']),
      garageName: m['garageName']?.toString() ?? m['centerName']?.toString(),
      amount: parseNum(m['amount'] ?? m['cost'] ?? m['price']),
      vehicleId: m['vehicleId']?.toString() ?? m['vehicle_id']?.toString(),
      notes: m['notes']?.toString(),
    );
  }

  MaintenanceHistory toEntity() => MaintenanceHistory(
        id: id,
        title: title,
        date: date,
        garageName: garageName,
        amount: amount,
        vehicleId: vehicleId,
        notes: notes,
      );
}

