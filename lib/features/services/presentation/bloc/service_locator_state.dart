library;

import 'package:equatable/equatable.dart';

import '../../domain/entities/service_center.dart';

class ServiceLocatorState extends Equatable {
  const ServiceLocatorState({
    required this.centers,
    required this.selectedCenterId,
    required this.visibleCenterIds,
    required this.isLoading,
    this.failureMessage,
  });

  final List<ServiceCenter> centers;
  final String? selectedCenterId;
  final List<String> visibleCenterIds;
  final bool isLoading;
  /// Non-null when a load failed (e.g. network or API error).
  final String? failureMessage;

  factory ServiceLocatorState.initial() => const ServiceLocatorState(
        centers: [],
        selectedCenterId: null,
        visibleCenterIds: [],
        isLoading: true,
        failureMessage: null,
      );

  ServiceLocatorState copyWith({
    List<ServiceCenter>? centers,
    String? selectedCenterId,
    bool clearSelectedCenter = false,
    List<String>? visibleCenterIds,
    bool? isLoading,
    String? failureMessage,
  }) {
    return ServiceLocatorState(
      centers: centers ?? this.centers,
      selectedCenterId: clearSelectedCenter ? null : (selectedCenterId ?? this.selectedCenterId),
      visibleCenterIds: visibleCenterIds ?? this.visibleCenterIds,
      isLoading: isLoading ?? this.isLoading,
      failureMessage: failureMessage,
    );
  }

  @override
  List<Object?> get props => [
        centers,
        selectedCenterId,
        visibleCenterIds,
        isLoading,
        failureMessage,
      ];
}

