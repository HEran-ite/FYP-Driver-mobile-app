library;

import '../../domain/entities/service_center.dart';

class ServiceCenterModel {
  const ServiceCenterModel({
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

  final String id;
  final String name;
  final String subtitle;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewsCount;
  final double distanceMiles;
  final bool isOpen;
  final bool isRegistered;
  final List<String> services;

  factory ServiceCenterModel.fromJson(Map<String, dynamic> json) {
    final servicesList = json['services'];
    List<String> services = [];
    if (servicesList is List) {
      for (final e in servicesList) {
        if (e is String) services.add(e);
        else if (e is Map && e['name'] != null) services.add(e['name'].toString());
      }
    }
    return ServiceCenterModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['garageName']?.toString() ?? 'Garage',
      subtitle: json['subtitle']?.toString() ?? json['address']?.toString() ?? '',
      latitude: _toDouble(json['latitude'] ?? json['lat'], 0.0),
      longitude: _toDouble(json['longitude'] ?? json['lng'], 0.0),
      rating: _toDouble(json['rating'], 0.0),
      reviewsCount: _toInt(json['reviewsCount'] ?? json['reviewCount'], 0),
      distanceMiles: _toDouble(json['distanceMiles'] ?? json['distance'], 0.0),
      isOpen: json['isOpen'] == true,
      isRegistered: json['isRegistered'] == true,
      services: services,
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
        latitude: latitude,
        longitude: longitude,
        rating: rating,
        reviewsCount: reviewsCount,
        distanceMiles: distanceMiles,
        isOpen: isOpen,
        isRegistered: isRegistered,
        services: services,
      );
}
