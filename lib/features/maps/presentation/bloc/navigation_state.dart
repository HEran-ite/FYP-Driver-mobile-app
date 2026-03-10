library;

import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// State for navigation start/origin.
class NavigationState extends Equatable {
  const NavigationState({
    this.customOrigin,
    this.customOriginName,
    this.selectingOriginOnMap = false,
  });

  /// Custom start point; null means use user's current location.
  final LatLng? customOrigin;
  final String? customOriginName;
  /// True when waiting for user to tap the map to set start point.
  final bool selectingOriginOnMap;

  bool get hasCustomOrigin => customOrigin != null;

  NavigationState copyWith({
    LatLng? customOrigin,
    String? customOriginName,
    bool clearOrigin = false,
    bool? selectingOriginOnMap,
  }) {
    return NavigationState(
      customOrigin: clearOrigin ? null : (customOrigin ?? this.customOrigin),
      customOriginName:
          clearOrigin ? null : (customOriginName ?? this.customOriginName),
      selectingOriginOnMap: selectingOriginOnMap ?? this.selectingOriginOnMap,
    );
  }

  @override
  List<Object?> get props => [
        customOrigin?.latitude,
        customOrigin?.longitude,
        customOriginName,
        selectingOriginOnMap,
      ];
}
