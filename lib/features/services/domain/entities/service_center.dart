library;

import 'package:equatable/equatable.dart';

class ServiceCenter extends Equatable {
  final String id;
  final String name;
  final String subtitle;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewsCount;
  final double distanceMiles;
  final bool isOpen;
  final bool isRegistered; // Registered via our app
  final bool onsiteServiceEnabled;
  final List<String> services;
  final List<GarageAvailabilitySlot> availabilitySlots;

  const ServiceCenter({
    required this.id,
    required this.name,
    required this.subtitle,
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

  @override
  List<Object?> get props => [
        id,
        name,
        subtitle,
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

