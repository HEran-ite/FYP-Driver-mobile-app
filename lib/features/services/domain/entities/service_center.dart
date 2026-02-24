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
  final List<String> services;

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
    required this.services,
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
        services,
      ];
}

