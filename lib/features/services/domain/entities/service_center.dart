library;

import 'package:equatable/equatable.dart';

/// A service offered by a garage ([id] from [GarageService] on the backend).
class GarageOfferedService extends Equatable {
  const GarageOfferedService({required this.id, required this.name});

  final String id;
  final String name;

  bool get canBookWithApi => id.isNotEmpty;

  @override
  List<Object?> get props => [id, name];
}

class ServiceCenter extends Equatable {
  final String id;
  final String name;
  final String subtitle;
  final String phone;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewsCount;
  final double distanceMiles;
  final bool isOpen;
  final bool isRegistered; // Registered via our app
  final bool onsiteServiceEnabled;
  final List<GarageOfferedService> services;
  final List<GarageAvailabilitySlot> availabilitySlots;

  const ServiceCenter({
    required this.id,
    required this.name,
    required this.subtitle,
    this.phone = '',
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewsCount,
    required this.distanceMiles,
    required this.isOpen,
    required this.isRegistered,
    required this.onsiteServiceEnabled,
    required this.services,
    this.availabilitySlots = const [],
  });

  ServiceCenter copyWith({
    String? id,
    String? name,
    String? subtitle,
    String? phone,
    double? latitude,
    double? longitude,
    double? rating,
    int? reviewsCount,
    double? distanceMiles,
    bool? isOpen,
    bool? isRegistered,
    bool? onsiteServiceEnabled,
    List<GarageOfferedService>? services,
    List<GarageAvailabilitySlot>? availabilitySlots,
  }) {
    return ServiceCenter(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      distanceMiles: distanceMiles ?? this.distanceMiles,
      isOpen: isOpen ?? this.isOpen,
      isRegistered: isRegistered ?? this.isRegistered,
      onsiteServiceEnabled: onsiteServiceEnabled ?? this.onsiteServiceEnabled,
      services: services ?? this.services,
      availabilitySlots: availabilitySlots ?? this.availabilitySlots,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    subtitle,
    phone,
    latitude,
    longitude,
    rating,
    reviewsCount,
    distanceMiles,
    isOpen,
    isRegistered,
    onsiteServiceEnabled,
    services,
    availabilitySlots,
  ];
}

class GarageAvailabilitySlot extends Equatable {
  final String dayOfWeek; // MONDAY..SUNDAY
  final int startMinute; // 0..1439
  final int endMinute; // 0..1439

  const GarageAvailabilitySlot({
    required this.dayOfWeek,
    required this.startMinute,
    required this.endMinute,
  });

  @override
  List<Object?> get props => [dayOfWeek, startMinute, endMinute];
}
