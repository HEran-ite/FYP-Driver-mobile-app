library;

import 'package:equatable/equatable.dart';

class DriverUser extends Equatable {
  const DriverUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  @override
  List<Object?> get props => [id, firstName, lastName, email, phone];
}
