library;

import 'package:equatable/equatable.dart';

import '../../domain/entities/service_center.dart';

class ServiceLocatorState extends Equatable {
  const ServiceLocatorState({
    required this.centers,
    required this.selectedCenterId,
    required this.visibleCenterIds,
    required this.isLoading,
    this.lastLatitude,
    this.lastLongitude,
    this.failureMessage,
  });

  final List<ServiceCenter> centers;
  final String? selectedCenterId;
  final List<String> visibleCenterIds;
  final bool isLoading;
  final double? lastLatitude;
  final double? lastLongitude;

  /// Non-null when a load failed (e.g. network or API error).
  final String? failureMessage;

  factory ServiceLocatorState.initial() => const ServiceLocatorState(
    centers: [],
    selectedCenterId: null,
    visibleCenterIds: [],
    isLoading: true,
    lastLatitude: null,
    lastLongitude: null,
    failureMessage: null,
  );

  ServiceLocatorState copyWith({
    List<ServiceCenter>? centers,
    String? selectedCenterId,
    bool clearSelectedCenter = false,
    List<String>? visibleCenterIds,
    bool? isLoading,
    double? lastLatitude,
    double? lastLongitude,
    String? failureMessage,
  }) {
    return ServiceLocatorState(
      centers: centers ?? this.centers,
      selectedCenterId: clearSelectedCenter
          ? null
          : (selectedCenterId ?? this.selectedCenterId),
      visibleCenterIds: visibleCenterIds ?? this.visibleCenterIds,
      isLoading: isLoading ?? this.isLoading,
      lastLatitude: lastLatitude ?? this.lastLatitude,
      lastLongitude: lastLongitude ?? this.lastLongitude,
      failureMessage: failureMessage,
    );
  }

  @override
  List<Object?> get props => [
    centers,
    selectedCenterId,
    visibleCenterIds,
    isLoading,
    lastLatitude,
    lastLongitude,
    failureMessage,
  ];
}
