library;

import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/vehicle_model.dart';
import 'vehicle_remote_datasource.dart';

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  VehicleRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<VehicleModel>> list() async {
    final res = await _dio.get<dynamic>(ApiEndpoints.driverVehicles);
    final raw = res.data;
    final List<dynamic> list = _extractList(raw);
    return list
        .map((e) => VehicleModel.fromJson(e is Map<String, dynamic> ? e : null))
        .where((v) => v.id.isNotEmpty)
        .toList();
  }

  List<dynamic> _extractList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw;
    if (raw is Map<String, dynamic>) {
      if (raw['data'] is List) return raw['data'] as List;
      if (raw['vehicles'] is List) return raw['vehicles'] as List;
      if (raw['items'] is List) return raw['items'] as List;
    }
    if (raw is Map) {
      final data = raw['data'];
      if (data is List) return data;
      final vehicles = raw['vehicles'];
      if (vehicles is List) return vehicles;
    }
    return [];
  }

  @override
  Future<VehicleModel> getById(String id) async {
    final res = await _dio.get<dynamic>(ApiEndpoints.driverVehicleById(id));
    final data = res.data;
    if (data is Map<String, dynamic>) return VehicleModel.fromJson(data);
    if (data is Map) return VehicleModel.fromJson(Map<String, dynamic>.from(data));
    return VehicleModel.fromJson(null);
  }

  @override
  Future<VehicleModel> add(
    Map<String, dynamic> body, {
    String? insuranceFilePath,
    String? registrationFilePath,
  }) async {
    final hasFiles = (insuranceFilePath != null && insuranceFilePath.isNotEmpty && File(insuranceFilePath).existsSync()) ||
        (registrationFilePath != null && registrationFilePath.isNotEmpty && File(registrationFilePath).existsSync());

    if (hasFiles) {
      final fields = <String, dynamic>{
        ...body.map((k, v) => MapEntry(k, v?.toString() ?? '')),
      };
      if (!fields.containsKey('plateNumber') || fields['plateNumber']!.isEmpty) {
        fields['plateNumber'] = body['plateNumber']?.toString() ?? '';
      }
      final formData = FormData.fromMap(fields);
      if (insuranceFilePath != null && insuranceFilePath.isNotEmpty) {
        final file = File(insuranceFilePath);
        if (file.existsSync()) {
          formData.files.add(MapEntry(
            'insuranceDocument',
            await MultipartFile.fromFile(insuranceFilePath, filename: insuranceFilePath.split(RegExp(r'[/\\]')).last),
          ));
        }
      }
      if (registrationFilePath != null && registrationFilePath.isNotEmpty) {
        final file = File(registrationFilePath);
        if (file.existsSync()) {
          formData.files.add(MapEntry(
            'registrationDocument',
            await MultipartFile.fromFile(registrationFilePath, filename: registrationFilePath.split(RegExp(r'[/\\]')).last),
          ));
        }
      }
      final res = await _dio.post<dynamic>(
        ApiEndpoints.driverVehicles,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      return _parseAddResponse(res.data, body);
    }

    final res = await _dio.post<dynamic>(
      ApiEndpoints.driverVehicles,
      data: body,
    );
    return _parseAddResponse(res.data, body);
  }

  VehicleModel _parseAddResponse(dynamic data, Map<String, dynamic> requestBody) {
    if (data is Map<String, dynamic>) {
      final parsed = VehicleModel.fromJson(data);
      if (parsed.id.isNotEmpty || parsed.plateNumber.isNotEmpty) return parsed;
    }
    final plateNumber = requestBody['plateNumber']?.toString() ?? '';
    final make = requestBody['make']?.toString() ?? '';
    final model = requestBody['model']?.toString() ?? '';
    final year = requestBody['year'] != null ? int.tryParse(requestBody['year'].toString()) ?? DateTime.now().year : DateTime.now().year;
    return VehicleModel(
      id: (data is Map && data['id'] != null) ? data['id'].toString() : '',
      driverId: (data is Map && data['driverId'] != null) ? data['driverId'].toString() : '',
      plateNumber: (data is Map && data['plateNumber'] != null) ? data['plateNumber'].toString() : plateNumber,
      make: (data is Map && data['make'] != null) ? data['make'].toString() : make,
      model: (data is Map && data['model'] != null) ? data['model'].toString() : model,
      year: (data is Map && data['year'] != null) ? (data['year'] is int ? data['year'] as int : int.tryParse(data['year'].toString()) ?? year) : year,
    );
  }

  @override
  Future<VehicleModel> update(
    String id,
    Map<String, dynamic> body, {
    String? insuranceFilePath,
    String? registrationFilePath,
  }) async {
    final hasFiles = (insuranceFilePath != null && insuranceFilePath.isNotEmpty && File(insuranceFilePath).existsSync()) ||
        (registrationFilePath != null && registrationFilePath.isNotEmpty && File(registrationFilePath).existsSync());

    if (hasFiles) {
      final fields = <String, dynamic>{
        ...body.map((k, v) => MapEntry(k, v?.toString() ?? '')),
      };
      final formData = FormData.fromMap(fields);
      if (insuranceFilePath != null && insuranceFilePath.isNotEmpty) {
        final file = File(insuranceFilePath);
        if (file.existsSync()) {
          formData.files.add(MapEntry(
            'insuranceDocument',
            await MultipartFile.fromFile(insuranceFilePath, filename: insuranceFilePath.split(RegExp(r'[/\\]')).last),
          ));
        }
      }
      if (registrationFilePath != null && registrationFilePath.isNotEmpty) {
        final file = File(registrationFilePath);
        if (file.existsSync()) {
          formData.files.add(MapEntry(
            'registrationDocument',
            await MultipartFile.fromFile(registrationFilePath, filename: registrationFilePath.split(RegExp(r'[/\\]')).last),
          ));
        }
      }
      final res = await _dio.put<dynamic>(
        ApiEndpoints.driverVehicleById(id),
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      final data = res.data;
      if (data is Map<String, dynamic>) return VehicleModel.fromJson(data);
      if (data is Map) return VehicleModel.fromJson(Map<String, dynamic>.from(data));
      return VehicleModel.fromJson(null);
    }

    final res = await _dio.put<dynamic>(
      ApiEndpoints.driverVehicleById(id),
      data: body,
    );
    final data = res.data;
    if (data is Map<String, dynamic>) return VehicleModel.fromJson(data);
    if (data is Map) return VehicleModel.fromJson(Map<String, dynamic>.from(data));
    return VehicleModel.fromJson(null);
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete(ApiEndpoints.driverVehicleById(id));
  }
}
