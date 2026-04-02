library;

import '../../domain/entities/service_center.dart';

class ServiceCenterModel {
  const ServiceCenterModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewsCount,
    required this.distanceMiles,
    required this.isOpen,
    required this.isRegistered,
    required this.onsiteServiceEnabled,
    required this.services,
    required this.availabilitySlots,
  });

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
  final bool isRegistered;
  final bool onsiteServiceEnabled;
  final List<GarageOfferedService> services;
  final List<GarageAvailabilitySlotModel> availabilitySlots;

  factory ServiceCenterModel.fromJson(Map<String, dynamic> json) {
    final servicesList = json['services'];
    final services = <GarageOfferedService>[];
    if (servicesList is List) {
      for (final e in servicesList) {
        if (e is String) {
          final n = e.trim();
          if (n.isNotEmpty) {
            services.add(GarageOfferedService(id: '', name: n));
          }
        } else if (e is Map) {
          final id = e['id']?.toString() ?? '';
          final name = (e['name'] ?? e['serviceName'])?.toString().trim() ?? '';
          if (name.isNotEmpty) {
            services.add(GarageOfferedService(id: id, name: name));
          }
        }
      }
    }
    // Prefer dedicated availability payload; fallback to nearby's availabilitySlots.
    final slotsRaw = json['availability'] ?? json['availabilitySlots'];
    final slots = <GarageAvailabilitySlotModel>[];
    if (slotsRaw is List) {
      for (final e in slotsRaw) {
        if (e is Map) {
          slots.add(
            GarageAvailabilitySlotModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          );
        }
      }
    }
    return ServiceCenterModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['garageName']?.toString() ?? 'Garage',
      subtitle: json['subtitle']?.toString() ?? json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ??
          json['phoneNumber']?.toString() ??
          json['contactPhone']?.toString() ??
          json['contact_number']?.toString() ??
          '',
      latitude: _toDouble(json['latitude'] ?? json['lat'], 0.0),
      longitude: _toDouble(json['longitude'] ?? json['lng'], 0.0),
      rating: _toDouble(json['rating'], 0.0),
      reviewsCount: _toInt(json['reviewsCount'] ?? json['reviewCount'], 0),
      distanceMiles: _toDouble(json['distanceMiles'] ?? json['distance'], 0.0),
      isOpen: json['isOpen'] == true,
      isRegistered: json['isRegistered'] == true,
      onsiteServiceEnabled: json['onsiteServiceEnabled'] == true,
      services: services,
      availabilitySlots: slots,
    );
  }

  static double _toDouble(dynamic v, double def) {
    if (v == null) return def;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? def;
    return def;
  }

  static int _toInt(dynamic v, int def) {
    if (v == null) return def;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? def;
    return def;
  }

  ServiceCenter toEntity() => ServiceCenter(
        id: id,
        name: name,
        subtitle: subtitle,
        phone: phone,
        latitude: latitude,
        longitude: longitude,
        rating: rating,
        reviewsCount: reviewsCount,
        distanceMiles: distanceMiles,
        isOpen: isOpen,
        isRegistered: isRegistered,
        onsiteServiceEnabled: onsiteServiceEnabled,
        services: services,
        availabilitySlots: availabilitySlots
            .map(
              (s) => GarageAvailabilitySlot(
                dayOfWeek: s.dayOfWeek,
                startMinute: s.startMinute,
                endMinute: s.endMinute,
              ),
            )
            .toList(),
      );
}

class GarageAvailabilitySlotModel {
  final String dayOfWeek;
  final int startMinute;
  final int endMinute;

  const GarageAvailabilitySlotModel({
    required this.dayOfWeek,
    required this.startMinute,
    required this.endMinute,
  });

  factory GarageAvailabilitySlotModel.fromJson(Map<String, dynamic> json) {
    return GarageAvailabilitySlotModel(
      dayOfWeek: json['dayOfWeek']?.toString() ?? 'MONDAY',
      startMinute: ServiceCenterModel._toInt(json['startMinute'], 0),
      endMinute: ServiceCenterModel._toInt(json['endMinute'], 0),
    );
  }
}
