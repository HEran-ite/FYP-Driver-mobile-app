library;

import '../../domain/entities/driver_user.dart';

class DriverResponse {
  const DriverResponse({
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

  factory DriverResponse.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'] ?? json['_id'];
    final id = idRaw == null ? '' : idRaw.toString();
    return DriverResponse(
      id: id,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  DriverUser toEntity() => DriverUser(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );
}
