library;

import 'package:equatable/equatable.dart';

class MaintenanceHistory extends Equatable {
  const MaintenanceHistory({
    required this.id,
    required this.title,
    required this.date,
    this.garageName,
    this.amount,
  });

  final String id;
  final String title;
  final DateTime date;
  final String? garageName;
  final num? amount;

  @override
  List<Object?> get props => [id, title, date, garageName, amount];
}

