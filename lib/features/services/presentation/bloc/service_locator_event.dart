library;

import 'package:equatable/equatable.dart';

class ServiceLocatorEvent extends Equatable {
  const ServiceLocatorEvent();

  @override
  List<Object?> get props => [];
}

class InitializeServiceLocator extends ServiceLocatorEvent {
  const InitializeServiceLocator();
}

/// (Re)fetch nearby garages. Optional [latitude] [longitude]; if null, uses mock/default.
class LoadNearbyGarages extends ServiceLocatorEvent {
  const LoadNearbyGarages({this.latitude, this.longitude});
  final double? latitude;
  final double? longitude;
  @override
  List<Object?> get props => [latitude, longitude];
}

class SelectServiceCenter extends ServiceLocatorEvent {
  final String centerId;

  const SelectServiceCenter(this.centerId);

  @override
  List<Object?> get props => [centerId];
}

/// Clear selected garage (e.g. when closing the info bottom sheet).
class ClearSelectedCenter extends ServiceLocatorEvent {
  const ClearSelectedCenter();
}

class UpdateVisibleCenters extends ServiceLocatorEvent {
  final List<String> visibleCenterIds;

  const UpdateVisibleCenters(this.visibleCenterIds);

  @override
  List<Object?> get props => [visibleCenterIds];
}

class RefreshNearbyGaragesRequested extends ServiceLocatorEvent {
  const RefreshNearbyGaragesRequested();
}
