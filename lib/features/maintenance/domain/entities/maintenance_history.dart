library;

import 'package:equatable/equatable.dart';

class MaintenanceHistory extends Equatable {
  const MaintenanceHistory({
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

  @override
  List<Object?> get props => [id, title, date, garageName, amount, vehicleId, notes];
}

