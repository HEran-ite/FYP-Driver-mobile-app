library;

import '../../domain/entities/vehicle.dart';

class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.driverId,
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.year,
    this.type,
    this.color,
    this.vin,
    this.mileage,
    this.fuelType,
    this.imageUrl,
    this.insuranceDocumentUrl,
    this.insuranceExpiresAt,
    this.registrationDocumentUrl,
    this.registrationExpiresAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String driverId;
  final String plateNumber;
  final String make;
  final String model;
  final int year;
  final String? type;
  final String? color;
  final String? vin;
  final int? mileage;
  final String? fuelType;
  final String? imageUrl;
  final String? insuranceDocumentUrl;
  final String? insuranceExpiresAt;
  final String? registrationDocumentUrl;
  final String? registrationExpiresAt;
  final String? createdAt;
  final String? updatedAt;

  factory VehicleModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return VehicleModel(
        id: '',
        driverId: '',
        plateNumber: '',
        make: '',
        model: '',
        year: DateTime.now().year,
      );
    }
    String _str(String key, [String fallback = '']) =>
        (json[key] ?? json[_snake(key)])?.toString().trim() ?? fallback;
    int _int(String key, [int fallback = 0]) {
      final v = json[key] ?? json[_snake(key)];
      if (v is int) return v;
      final n = int.tryParse(v?.toString() ?? '');
      return n ?? fallback;
    }
    final mileageVal = json['mileage'] ?? json[_snake('mileage')];
    final mileage = mileageVal != null ? _int('mileage') : null;
    return VehicleModel(
      id: _str('id', ''),
      driverId: _str('driverId', ''),
      plateNumber: _str('plateNumber', ''),
      make: _str('make', ''),
      model: _str('model', ''),
      year: _int('year', DateTime.now().year),
      type: _str('type').isEmpty ? null : _str('type'),
      color: _str('color').isEmpty ? null : _str('color'),
      vin: _str('vin').isEmpty ? null : _str('vin'),
      mileage: mileage,
      fuelType: _str('fuelType').isEmpty ? null : _str('fuelType'),
      imageUrl: _str('imageUrl').isEmpty ? null : _str('imageUrl'),
      insuranceDocumentUrl: _str('insuranceDocumentUrl').isEmpty ? null : _str('insuranceDocumentUrl'),
      insuranceExpiresAt: json['insuranceExpiresAt']?.toString(),
      registrationDocumentUrl: _str('registrationDocumentUrl').isEmpty ? null : _str('registrationDocumentUrl'),
      registrationExpiresAt: json['registrationExpiresAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  static String _snake(String camel) {
    final sb = StringBuffer();
    for (var i = 0; i < camel.length; i++) {
      final c = camel[i];
      if (c.toUpperCase() == c && c != c.toLowerCase()) {
        sb.write('_');
        sb.write(c.toLowerCase());
      } else {
        sb.write(c);
      }
    }
    return sb.toString();
  }

  Vehicle toEntity() {
    return Vehicle(
      id: id,
      driverId: driverId,
      plateNumber: plateNumber,
      make: make,
      model: model,
      year: year,
      type: type,
      color: color,
      vin: vin,
      mileage: mileage,
      fuelType: fuelType,
      imageUrl: imageUrl,
      insuranceDocumentUrl: insuranceDocumentUrl,
      insuranceExpiresAt: insuranceExpiresAt != null ? DateTime.tryParse(insuranceExpiresAt!) : null,
      registrationDocumentUrl: registrationDocumentUrl,
      registrationExpiresAt: registrationExpiresAt != null ? DateTime.tryParse(registrationExpiresAt!) : null,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }
}
