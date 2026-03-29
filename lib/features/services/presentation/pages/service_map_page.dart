import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    hide TravelMode;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/service_locator.dart';
import '../../domain/entities/service_center.dart';
import '../../../appointments/presentation/bloc/appointments_bloc.dart';
import '../../../appointments/presentation/bloc/appointments_event.dart';
import '../../../appointments/presentation/bloc/appointments_state.dart';
import '../../../maps/domain/entities/route_info.dart';
import '../../../maps/presentation/bloc/directions_bloc.dart';
import '../../../maps/presentation/bloc/directions_event.dart';
import '../../../maps/presentation/bloc/directions_state.dart';
import '../../../maps/presentation/bloc/places_bloc.dart';
import '../../../maps/presentation/bloc/places_event.dart';
import '../../../maps/presentation/bloc/places_state.dart';
import '../../../maps/presentation/bloc/map_bloc.dart';
import '../../../maps/presentation/bloc/map_event.dart';
import '../../../maps/presentation/bloc/map_state.dart';
import '../bloc/service_locator_bloc.dart';
import '../bloc/service_locator_event.dart';
import '../bloc/service_locator_state.dart';
import 'book_service_wizard_page.dart';
import '../widgets/service_tag_chip.dart';

/// Default fallback when location is unavailable (San Francisco).
const double _defaultLat = 37.7749;
const double _defaultLng = -122.4194;

enum _MapCategory {
  garages,
  gasStations,
  carWash,
  hotels,
  parking,
  evCharging,
  tireShop,
  towing,
}

class ServiceMapPage extends StatefulWidget {
  final String? initialCenterId;
  final bool autoNavigate;

  const ServiceMapPage({super.key, this.initialCenterId, this.autoNavigate = false});

  @override
  State<ServiceMapPage> createState() => _ServiceMapPageState();
}

class _ServiceMapPageState extends State<ServiceMapPage> {
  GoogleMapController? _mapController;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchResults = false;
  Set<Polyline> _routePolylines = {};
  final List<_RecentPlace> _recentDestinations = [];
  StreamSubscription<Position>? _positionSubscription;
  BitmapDescriptor? _garageCarMarkerIcon;
  // When true, user has interacted (tapped) with a center on this screen.
  // We use this to avoid opening the bottom sheet automatically on page open.
  bool _userSelectedCenter = false;
  bool _didAutoNavigate = false;
  _MapCategory _selectedCategory = _MapCategory.garages;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<ServiceLocatorBloc>();
    if (widget.initialCenterId != null) {
      bloc.add(SelectServiceCenter(widget.initialCenterId!));
    }
    _resolveUserLocation();
    _loadMarkerIcon();
  }

  void _maybeAutoNavigate(ServiceLocatorState state, LatLng? userLocation) {
    if (!widget.autoNavigate || _didAutoNavigate) return;
    if (widget.initialCenterId == null) return;
    ServiceCenter? center;
    try {
      center = state.centers.firstWhere((c) => c.id == widget.initialCenterId);
    } catch (_) {
      center = null;
    }
    if (center == null) return;
    final selectedCenter = center;
    _didAutoNavigate = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _userSelectedCenter = true);
      context.read<ServiceLocatorBloc>().add(SelectServiceCenter(selectedCenter.id));
      _focusOnCenter(selectedCenter);
      _navigateInApp(selectedCenter, userLocation);
    });
  }

  Future<void> _loadMarkerIcon() async {
    try {
      final bytes = await _iconToPngBytes(
        icon: Icons.garage_rounded,
        color: const Color(0xFF1DB954),
        size: 96,
      );
      if (!mounted) return;
      setState(() {
        _garageCarMarkerIcon = BitmapDescriptor.fromBytes(bytes);
      });
    } catch (_) {
      // Fallback handled in _buildMarkers.
    }
  }

  Future<Uint8List> _iconToPngBytes({
    required IconData icon,
    required Color color,
    required double size,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: color,
      ),
    );
    textPainter.layout();
    final pad = size * 0.25;
    final imgW = (textPainter.width + pad * 2).ceil();
    final imgH = (textPainter.height + pad * 2).ceil();
    textPainter.paint(canvas, Offset(pad, pad));
    final picture = recorder.endRecording();
    final image = await picture.toImage(imgW, imgH);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _resolveUserLocation() async {
    final status = await Permission.locationWhenInUse.request();
    if (!mounted) return;
    if (!status.isGranted) {
      context.read<MapBloc>().add(
        const MapUserLocationUnavailable(permissionDenied: true),
      );
      return;
    }
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted)
          context.read<MapBloc>().add(
            const MapUserLocationUnavailable(permissionDenied: false),
          );
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      if (!mounted) return;
      final latLng = LatLng(position.latitude, position.longitude);
      context.read<MapBloc>().add(MapUserLocationUpdated(latLng));
      context.read<ServiceLocatorBloc>().add(
        LoadNearbyGarages(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));
      }
    } on TimeoutException catch (_) {
      if (mounted)
        context.read<MapBloc>().add(
          const MapUserLocationUnavailable(permissionDenied: false),
        );
    } on LocationServiceDisabledException catch (_) {
      if (mounted)
        context.read<MapBloc>().add(
          const MapUserLocationUnavailable(permissionDenied: false),
        );
    } catch (_) {
      if (mounted)
        context.read<MapBloc>().add(
          const MapUserLocationUnavailable(permissionDenied: false),
        );
    }
  }

  LatLng _initialTarget(ServiceLocatorState state, LatLng? userLocation) {
    if (userLocation != null) return userLocation;
    final center = _getSelectedCenter(state);
    if (center != null) return LatLng(center.latitude, center.longitude);
    if (state.centers.isNotEmpty) {
      final c = state.centers.first;
      return LatLng(c.latitude, c.longitude);
    }
    return const LatLng(_defaultLat, _defaultLng);
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _onSearchChanged(String query, LatLng? userLocation) {
    if (query.isEmpty) {
      setState(() => _showSearchResults = false);
      context.read<PlacesBloc>().add(const PlacesCleared());
    } else {
      setState(() => _showSearchResults = true);
      context.read<PlacesBloc>().add(
        PlacesSearchRequested(
            query: query,
          lat: userLocation?.latitude,
          lng: userLocation?.longitude,
        ),
      );
    }
  }

  void _onPlaceSelected(String placeId) {
    _searchFocusNode.unfocus();
    setState(() => _showSearchResults = false);
    context.read<PlacesBloc>().add(PlaceSelected(placeId));
  }

  void _onCategorySelected(_MapCategory category, LatLng? userLocation) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _userSelectedCenter = false;
    });
    context.read<ServiceLocatorBloc>().add(const ClearSelectedCenter());

    if (category == _MapCategory.garages) {
      return;
    }
    if (userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location required to load nearby places')),
      );
      return;
    }
    final spec = _categorySpec(category);
    context.read<PlacesBloc>().add(
      NearbyPlacesRequested(
        lat: userLocation.latitude,
        lng: userLocation.longitude,
        type: spec.type,
        keyword: spec.keyword,
      ),
    );
  }

  void _getDirectionsToServiceCenter(
    ServiceCenter center,
    LatLng? userLocation,
  ) {
    if (userLocation == null) return;

    context.read<DirectionsBloc>().add(
      DirectionsRequested(
        origin: userLocation,
          destination: LatLng(center.latitude, center.longitude),
      ),
    );
  }

  void _getDirectionsToPlace(
    LatLng destination,
    LatLng? userLocation,
  ) {
    if (userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current location is required for routing')),
      );
      return;
    }
    context.read<DirectionsBloc>().add(
      DirectionsRequested(
        origin: userLocation,
        destination: destination,
      ),
    );
  }

  void _onMapTappedForRoute(LatLng destination, LatLng? userLocation) {
    _focusOnLatLng(destination);
    _getDirectionsToPlace(destination, userLocation);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Route updated to tapped location'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearDirections() {
    context.read<MapBloc>().add(const MapLiveTrackingToggled(enabled: false));
    _positionSubscription?.cancel();
    _positionSubscription = null;
    context.read<DirectionsBloc>().add(const DirectionsCleared());
    context.read<PlacesBloc>().add(const PlacesCleared());
    _searchController.clear();
    setState(() {
      _routePolylines = {};
      _showSearchResults = false;
    });
  }

  void _openLayersSheet(BuildContext context, MapType currentType) {
    final mapBloc = context.read<MapBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: Spacing.sm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                'Map type',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Spacing.md),
              _LayersOption(
                label: 'Default',
                isSelected: currentType == MapType.normal,
                onTap: () {
                  mapBloc.add(const MapTypeChanged(MapType.normal));
                  Navigator.of(ctx).pop();
                },
              ),
              _LayersOption(
                label: 'Satellite',
                isSelected: currentType == MapType.satellite,
                onTap: () {
                  mapBloc.add(const MapTypeChanged(MapType.satellite));
                  Navigator.of(ctx).pop();
                },
              ),
              _LayersOption(
                label: 'Hybrid',
                isSelected: currentType == MapType.hybrid,
                onTap: () {
                  mapBloc.add(const MapTypeChanged(MapType.hybrid));
                  Navigator.of(ctx).pop();
                },
              ),
              _LayersOption(
                label: 'Terrain',
                isSelected: currentType == MapType.terrain,
                onTap: () {
                  mapBloc.add(const MapTypeChanged(MapType.terrain));
                  Navigator.of(ctx).pop();
                },
              ),
              const SizedBox(height: Spacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _openDirectionSheet() {
    final placesBloc = context.read<PlacesBloc>();
    final directionsBloc = context.read<DirectionsBloc>();
    final mapBloc = context.read<MapBloc>();
    final mapState = mapBloc.state;
    placesBloc.add(const PlacesCleared());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider<PlacesBloc>.value(value: placesBloc),
          BlocProvider<DirectionsBloc>.value(value: directionsBloc),
          BlocProvider<MapBloc>.value(value: mapBloc),
        ],
        child: _DirectionSheet(
          userLocation: mapState.userLocation,
          initialOriginLatLng: mapState.customOriginLatLng,
          initialOriginName: mapState.customOriginName,
          recentDestinations: _recentDestinations,
          onRequestDirections:
              (
                LatLng origin,
                LatLng destination,
                String destinationName,
                TravelMode mode,
              ) {
                _addRecent(
                  destinationName,
                  destination.latitude,
                  destination.longitude,
                );
                directionsBloc.add(
                  DirectionsRequested(
                  origin: origin,
                  destination: destination,
                  mode: mode,
                  ),
                );
          },
          onClose: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _onMapLongPress(LatLng position) {
    final mapBloc = context.read<MapBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Use this point as start location?',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        mapBloc.add(
                          MapCustomOriginSet(
                            position: position,
                            displayName: 'Dropped pin',
                          ),
                        );
                        Navigator.of(ctx).pop();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Start location set. Open Directions to use it.',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.trip_origin, size: 20),
                      label: const Text('Set as start'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addRecent(String name, double lat, double lng) {
    setState(() {
      _recentDestinations.removeWhere((p) => p.lat == lat && p.lng == lng);
      _recentDestinations.insert(
        0,
        _RecentPlace(name: name, lat: lat, lng: lng),
      );
      if (_recentDestinations.length > 5) _recentDestinations.removeLast();
    });
  }

  void _onLocationPressed(LatLng? userLocation) {
    if (userLocation == null) return;
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLocation, 16));
    final hasRoute = context.read<DirectionsBloc>().state.hasRoute;
    final mapBloc = context.read<MapBloc>();
    if (hasRoute && !mapBloc.state.liveTracking) {
      mapBloc.add(const MapLiveTrackingToggled(enabled: true));
      _startLiveTracking();
    } else if (!hasRoute) {
      mapBloc.add(const MapLiveTrackingToggled(enabled: false));
      _positionSubscription?.cancel();
      _positionSubscription = null;
    }
  }

  void _startLiveTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream().listen((
      Position position,
    ) {
      if (!mounted) return;
      if (!context.read<MapBloc>().state.liveTracking) return;
      final latLng = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void _buildRoutePolylines(DirectionsState state) {
    if (!state.hasRoute) {
      setState(() => _routePolylines = {});
      return;
    }

    final polylines = <Polyline>{};
    for (int i = 0; i < state.routes.length; i++) {
      final route = state.routes[i];
      final isSelected = i == state.selectedRouteIndex;
      final points = PolylinePoints.decodePolyline(
        route.encodedPolyline,
      ).map((p) => LatLng(p.latitude, p.longitude)).toList();

      polylines.add(
        Polyline(
        polylineId: PolylineId('route_$i'),
        points: points,
          color: isSelected
              ? AppColors.primary
              : AppColors.textSecondary.withOpacity(0.5),
        width: isSelected ? 5 : 3,
          patterns: isSelected
              ? []
              : [PatternItem.dash(10), PatternItem.gap(5)],
        zIndex: isSelected ? 2 : 1,
        onTap: () {
          context.read<DirectionsBloc>().add(RouteAlternativeSelected(i));
        },
        ),
      );
    }

    setState(() => _routePolylines = polylines);

    final selectedRoute = state.selectedRoute;
    if (selectedRoute != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(selectedRoute.bounds, 80),
      );
    }
  }

  void _navigateInApp(ServiceCenter center, LatLng? userLocation) {
    // In-app navigation: draw the route polyline immediately.
    _getDirectionsToServiceCenter(center, userLocation);
  }

  void _onBookAppointment(ServiceCenter center) {
    // Hide the selected center bottom sheet before pushing the wizard page.
    context.read<ServiceLocatorBloc>().add(const ClearSelectedCenter());
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookServiceWizardPage(center: center),
      ),
    );
  }

  void _onRequestOnSite(ServiceCenter center, LatLng? userLocation) {
    if (userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Turn on location access so we can send the garage your position for on-site service.',
          ),
        ),
      );
      return;
    }
    context.read<ServiceLocatorBloc>().add(const ClearSelectedCenter());
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookServiceWizardPage(
          center: center,
          isOnsite: true,
          serviceLatitude: userLocation.latitude,
          serviceLongitude: userLocation.longitude,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AppointmentsBloc>()..add(const AppointmentsLoadRequested()),
      child: MultiBlocListener(
      listeners: [
        BlocListener<AppointmentsBloc, AppointmentsState>(
          listener: (context, state) {
            if (state is AppointmentActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Appointment booked successfully'),
                  ),
              );
            }
            if (state is AppointmentsFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
        BlocListener<DirectionsBloc, DirectionsState>(
          listener: (context, state) {
            _buildRoutePolylines(state);
          },
        ),
        BlocListener<PlacesBloc, PlacesState>(
          listener: (context, state) {
            if (state.selectedPlace != null) {
              final place = state.selectedPlace!;
              final userLocation = context.read<MapBloc>().state.userLocation;
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(place.latitude, place.longitude),
                  15,
                ),
              );
              if (userLocation != null) {
                context.read<DirectionsBloc>().add(
                  DirectionsRequested(
                    origin: userLocation,
                    destination: LatLng(place.latitude, place.longitude),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Current location is required for routing'),
                  ),
                );
              }
            }
          },
        ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.surface,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: AppColors.border,
        ),
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: BlocBuilder<MapBloc, MapState>(
            buildWhen: (a, b) =>
                a.userLocation != b.userLocation ||
                a.mapType != b.mapType ||
                a.locationResolved != b.locationResolved ||
                a.liveTracking != b.liveTracking,
            builder: (context, mapState) {
              return BlocBuilder<ServiceLocatorBloc, ServiceLocatorState>(
          builder: (context, state) {
                  if (state.isLoading && state.centers.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failureMessage != null && state.centers.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.danger,
                      ),
                      const SizedBox(height: Spacing.md),
                      Text(
                        state.failureMessage!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
                  if (!mapState.locationResolved) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: Spacing.md),
                    Text('Getting your location...'),
                  ],
                ),
              );
            }

                  final userLocation = mapState.userLocation;
                  _maybeAutoNavigate(state, userLocation);
                  final initialTarget = _initialTarget(
                    state,
                    mapState.userLocation,
                  );
                  return BlocBuilder<PlacesBloc, PlacesState>(
                    buildWhen: (a, b) =>
                        a.nearbyPlaces != b.nearbyPlaces ||
                        a.isLoadingNearby != b.isLoadingNearby,
                    builder: (context, placesState) {
                      final markers = _buildMarkers(
                        state,
                        placesState,
                        userLocation,
                      );
            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialTarget,
                    zoom: 13,
                  ),
                  markers: markers,
                  polylines: _routePolylines,
                        mapType: mapState.mapType,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  compassEnabled: true,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onCameraIdle: () {},
                        onTap: (pos) => _onMapTappedForRoute(pos, userLocation),
                        onLongPress: _onMapLongPress,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: SafeArea(
                    bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              Spacing.sm,
                              Spacing.sm,
                              Spacing.sm,
                              Spacing.sm,
                            ),
                    child: Column(
                      children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                _GoogleMapsIconButton(
                                  icon: Icons.arrow_back,
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              const SizedBox(width: Spacing.sm),
                              Expanded(
                                  child: _GoogleMapsSearchBar(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                    onChanged: (q) =>
                                        _onSearchChanged(q, userLocation),
                                  onClear: _clearDirections,
                                ),
                              ),
                                  ],
                                ),
                                const SizedBox(height: Spacing.sm),
                                _MapCategoryChips(
                                  selected: _selectedCategory,
                                  onSelected: (c) =>
                                      _onCategorySelected(c, userLocation),
                                ),
                                if (_selectedCategory != _MapCategory.garages &&
                                    placesState.isLoadingNearby)
                                  const Padding(
                                    padding: EdgeInsets.only(top: Spacing.xs),
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                ),
                              ),
                            ],
                          ),
                    ),
                  ),
                ),
                if (_showSearchResults)
                  Positioned(
                    left: Spacing.md,
                    right: Spacing.md,
                          top: 100,
                    child: _SearchResultsOverlay(
                      onPlaceSelected: _onPlaceSelected,
                      onClear: _clearDirections,
                      searchController: _searchController,
                    ),
                  ),
                BlocBuilder<DirectionsBloc, DirectionsState>(
                  builder: (context, dirState) {
                    if (dirState.hasRoute) {
                      return Positioned(
                        left: Spacing.md,
                        right: Spacing.md,
                        top: 80,
                        child: _RouteInfoCard(
                          route: dirState.selectedRoute!,
                          alternativesCount: dirState.routes.length,
                          selectedIndex: dirState.selectedRouteIndex,
                          travelMode: dirState.travelMode,
                          onAlternativeSelected: (i) {
                                  context.read<DirectionsBloc>().add(
                                    RouteAlternativeSelected(i),
                                  );
                          },
                          onTravelModeChanged: (mode) {
                                  context.read<DirectionsBloc>().add(
                                    TravelModeChanged(mode),
                                  );
                          },
                          onClose: _clearDirections,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Positioned(
                  right: Spacing.md,
                        bottom: 200,
                  child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                            _GoogleMapsLayersButton(
                              onTap: () =>
                                  _openLayersSheet(context, mapState.mapType),
                      ),
                      const SizedBox(height: Spacing.xs),
                            _GoogleMapsZoomControl(
                              onZoomIn: _zoomIn,
                              onZoomOut: _zoomOut,
                      ),
                      const SizedBox(height: Spacing.xs),
                            _GoogleMapsIconButton(
                              icon: Icons.my_location,
                              size: 48,
                              onPressed: () => _onLocationPressed(userLocation),
                              highlight: mapState.liveTracking,
                            ),
                            const SizedBox(height: Spacing.sm),
                            _GoogleMapsIconButton(
                              icon: Icons.directions,
                              size: 48,
                              onPressed: _openDirectionSheet,
                              filled: true,
                      ),
                    ],
                  ),
                ),
                          if (_selectedCategory == _MapCategory.garages &&
                              state.selectedCenterId != null &&
                              _userSelectedCenter)
                Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Material(
                            elevation: 8,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: _SelectedCenterBottomSheet(
                              userLocation: userLocation,
                              onBook: _onBookAppointment,
                              onNavigate: (c) =>
                                  _navigateInApp(c, userLocation),
                              onGetDirections: (c) =>
                                  _getDirectionsToServiceCenter(
                                    c,
                                    userLocation,
                                  ),
                              onRequestOnSite: (c) =>
                                  _onRequestOnSite(c, userLocation),
                              onClose: () => context
                                  .read<ServiceLocatorBloc>()
                                  .add(const ClearSelectedCenter()),
                            ),
                  ),
                ),
              ],
                      );
                    },
                  );
                },
            );
          },
        ),
        ),
        ),
      ),
    );
  }

  Set<Marker> _buildMarkers(
    ServiceLocatorState state,
    PlacesState placesState,
    LatLng? userLocation,
  ) {
    if (_selectedCategory != _MapCategory.garages) {
      final spec = _categorySpec(_selectedCategory);
      return placesState.nearbyPlaces.map((p) {
        return Marker(
          markerId: MarkerId('${_selectedCategory.name}_${p.placeId}'),
          position: LatLng(p.latitude, p.longitude),
          infoWindow: InfoWindow(
            title: p.name,
            snippet: p.formattedAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(spec.markerHue),
          onTap: () {
            final destination = LatLng(p.latitude, p.longitude);
            _focusOnLatLng(destination);
            _getDirectionsToPlace(destination, userLocation);
          },
        );
      }).toSet();
    }

    final bloc = context.read<ServiceLocatorBloc>();
    return state.centers.map((center) {
      final fallbackHue = center.isRegistered
          ? BitmapDescriptor.hueGreen
          : BitmapDescriptor.hueOrange;
      final icon = center.isRegistered && _garageCarMarkerIcon != null
          ? _garageCarMarkerIcon!
          : BitmapDescriptor.defaultMarkerWithHue(fallbackHue);

      return Marker(
        markerId: MarkerId(center.id),
        position: LatLng(center.latitude, center.longitude),
        icon: icon,
        onTap: () {
          context.read<PlacesBloc>().add(const PlacesCleared());
          setState(() => _userSelectedCenter = true);
          bloc.add(SelectServiceCenter(center.id));
          _focusOnCenter(center);
        },
      );
    }).toSet();
  }

  void _focusOnCenter(ServiceCenter center) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(center.latitude, center.longitude)),
    );
  }

  void _focusOnLatLng(LatLng latLng) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  }
}

class _CategorySpec {
  final String label;
  final IconData icon;
  final String? type;
  final String? keyword;
  final double markerHue;

  const _CategorySpec({
    required this.label,
    required this.icon,
    required this.type,
    required this.keyword,
    required this.markerHue,
  });
}

_CategorySpec _categorySpec(_MapCategory c) {
  switch (c) {
    case _MapCategory.garages:
      return const _CategorySpec(
        label: 'Garages',
        icon: Icons.garage_rounded,
        type: 'car_repair',
        keyword: 'garage',
        markerHue: BitmapDescriptor.hueGreen,
      );
    case _MapCategory.gasStations:
      return const _CategorySpec(
        label: 'Gas Stations',
        icon: Icons.local_gas_station_rounded,
        type: 'gas_station',
        keyword: null,
        markerHue: BitmapDescriptor.hueAzure,
      );
    case _MapCategory.carWash:
      return const _CategorySpec(
        label: 'Car Wash',
        icon: Icons.local_car_wash_rounded,
        type: 'car_wash',
        keyword: null,
        markerHue: BitmapDescriptor.hueViolet,
      );
    case _MapCategory.hotels:
      return const _CategorySpec(
        label: 'Hotels',
        icon: Icons.hotel_rounded,
        type: 'lodging',
        keyword: 'hotel',
        markerHue: BitmapDescriptor.hueOrange,
      );
    case _MapCategory.parking:
      return const _CategorySpec(
        label: 'Parking',
        icon: Icons.local_parking_rounded,
        type: 'parking',
        keyword: null,
        markerHue: BitmapDescriptor.hueCyan,
      );
    case _MapCategory.evCharging:
      return const _CategorySpec(
        label: 'EV Charging',
        icon: Icons.ev_station_rounded,
        type: 'electric_vehicle_charging_station',
        keyword: 'ev charging',
        markerHue: BitmapDescriptor.hueBlue,
      );
    case _MapCategory.tireShop:
      return const _CategorySpec(
        label: 'Tire Shop',
        icon: Icons.tire_repair_rounded,
        type: 'car_repair',
        keyword: 'tire shop',
        markerHue: BitmapDescriptor.hueMagenta,
      );
    case _MapCategory.towing:
      return const _CategorySpec(
        label: 'Towing',
        icon: Icons.car_crash_rounded,
        type: 'car_repair',
        keyword: 'towing',
        markerHue: BitmapDescriptor.hueRose,
      );
  }
}

class _MapCategoryChips extends StatelessWidget {
  const _MapCategoryChips({
    required this.selected,
    required this.onSelected,
  });

  final _MapCategory selected;
  final void Function(_MapCategory category) onSelected;

  @override
  Widget build(BuildContext context) {
    final categories = _MapCategory.values;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((c) {
          final isSelected = c == selected;
          final spec = _categorySpec(c);
          return Padding(
            padding: const EdgeInsets.only(right: Spacing.xs),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    spec.icon,
                    size: 16,
                    color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    spec.label,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(c),
              selectedColor: AppColors.secondary,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.secondary : AppColors.border,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Google Maps–style dark icon button (top bar, right controls).
class _GoogleMapsIconButton extends StatelessWidget {
  const _GoogleMapsIconButton({
    required this.icon,
    required this.onPressed,
    this.size = 40,
    this.highlight = false,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final bool highlight;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(size / 2),
      elevation: filled ? 0 : 1,
      shadowColor: AppColors.shadow,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: size * 0.5,
            color: filled
                ? AppColors.secondary
                : (highlight ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// Google Maps–style pill search bar (light mode).
class _GoogleMapsSearchBar extends StatelessWidget {
  const _GoogleMapsSearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
          decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: Spacing.md),
          Icon(Icons.search, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search here',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                isDense: true,
              ),
              onChanged: onChanged,
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox(width: 8);
              return IconButton(
                icon: Icon(
                  Icons.close,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  controller.clear();
                  onClear();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Single "Layers" button (light mode).
class _GoogleMapsLayersButton extends StatelessWidget {
  const _GoogleMapsLayersButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      elevation: 1,
      shadowColor: AppColors.shadow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(Icons.layers, color: AppColors.textPrimary, size: 24),
        ),
      ),
    );
  }
}

/// Combined zoom in/out control (light mode).
class _GoogleMapsZoomControl extends StatelessWidget {
  const _GoogleMapsZoomControl({
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      elevation: 1,
      shadowColor: AppColors.shadow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 44,
            child: IconButton(
              icon: Icon(Icons.add, color: AppColors.textPrimary, size: 24),
              onPressed: onZoomIn,
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ),
            ),
          ),
          Container(width: 48, height: 1, color: AppColors.border),
          SizedBox(
            width: 48,
            height: 44,
            child: IconButton(
              icon: Icon(Icons.remove, color: AppColors.textPrimary, size: 24),
              onPressed: onZoomOut,
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One row in the Layers bottom sheet (light mode).
class _LayersOption extends StatelessWidget {
  const _LayersOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: AppColors.primary, size: 22)
          : null,
      onTap: onTap,
    );
  }
}

class _RecentPlace {
  const _RecentPlace({
    required this.name,
    required this.lat,
    required this.lng,
  });
  final String name;
  final double lat;
  final double lng;
}

class _DirectionSheet extends StatefulWidget {
  const _DirectionSheet({
    required this.userLocation,
    this.initialOriginLatLng,
    this.initialOriginName,
    required this.recentDestinations,
    required this.onRequestDirections,
    required this.onClose,
  });

  final LatLng? userLocation;
  final LatLng? initialOriginLatLng;
  final String? initialOriginName;
  final List<_RecentPlace> recentDestinations;
  final void Function(
    LatLng origin,
    LatLng destination,
    String destinationName,
    TravelMode mode,
  )
  onRequestDirections;
  final VoidCallback onClose;

  @override
  State<_DirectionSheet> createState() => _DirectionSheetState();
}

class _DirectionSheetState extends State<_DirectionSheet> {
  late final TextEditingController _originController;
  late final TextEditingController _destinationController;
  late final FocusNode _originFocusNode;
  late final FocusNode _destinationFocusNode;
  TravelMode _travelMode = TravelMode.driving;

  /// Custom origin when user searches or set from map; null means use "Your location".
  LatLng? _selectedOriginLatLng;

  /// True when the last search was for origin (so we apply selectedPlace to origin, not destination).
  bool _lastSearchWasOrigin = false;

  LatLng? get _effectiveOrigin => _selectedOriginLatLng ?? widget.userLocation;

  @override
  void initState() {
    super.initState();
    _originController = TextEditingController(
      text: widget.initialOriginName ?? '',
    );
    _destinationController = TextEditingController();
    _originFocusNode = FocusNode();
    _destinationFocusNode = FocusNode();
    _selectedOriginLatLng = widget.initialOriginLatLng;
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _originFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: Spacing.sm),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.sm,
              Spacing.sm,
              Spacing.sm,
              Spacing.xs,
            ),
            child: Row(
            children: [
              IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                onPressed: widget.onClose,
                style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        BorderRadiusValues.lg,
                      ),
                    ),
                ),
              ),
              Expanded(
                child: Text(
                  'Directions',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  textAlign: TextAlign.center,
                ),
              ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: widget.onClose,
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        BorderRadiusValues.lg,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: BlocListener<PlacesBloc, PlacesState>(
                listener: (context, state) {
                  if (state.selectedPlace != null) {
                    final place = state.selectedPlace!;
                  if (_lastSearchWasOrigin) {
                    final latLng = LatLng(place.latitude, place.longitude);
                    setState(() {
                      _selectedOriginLatLng = latLng;
                      _originController.text = place.name;
                    });
                    context.read<MapBloc>().add(
                      MapCustomOriginSet(
                        position: latLng,
                        displayName: place.name,
                      ),
                    );
                    context.read<PlacesBloc>().add(const PlacesCleared());
                  } else {
                    final origin = _effectiveOrigin;
                    if (origin != null) {
                      widget.onRequestDirections(
                        origin,
                        LatLng(place.latitude, place.longitude),
                        place.name,
                        _travelMode,
                      );
                      context.read<PlacesBloc>().add(const PlacesCleared());
                      widget.onClose();
                    }
                  }
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.lg,
                  Spacing.xs,
                  Spacing.lg,
                  Spacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(Spacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                                width: 32,
                                height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                                child: const Icon(
                                  Icons.trip_origin,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                        ),
                        const SizedBox(width: Spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                      'From',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    TextField(
                                      controller: _originController,
                                      focusNode: _originFocusNode,
                                      decoration: InputDecoration(
                                        hintText: widget.userLocation != null
                                            ? 'Your location'
                                            : 'Add origin',
                                        hintStyle: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 15,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                      onChanged: (q) {
                                        if (q.isEmpty) {
                                          setState(
                                            () => _selectedOriginLatLng = null,
                                          );
                                          context.read<MapBloc>().add(
                                            const MapCustomOriginCleared(),
                                          );
                                          context.read<PlacesBloc>().add(
                                            const PlacesCleared(),
                                          );
                                        } else {
                                          _lastSearchWasOrigin = true;
                                          context.read<PlacesBloc>().add(
                                            PlacesSearchRequested(
                                              query: q,
                                              lat:
                                                  widget.userLocation?.latitude,
                                              lng: widget
                                                  .userLocation
                                                  ?.longitude,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    if (_effectiveOrigin != null &&
                                        _selectedOriginLatLng != null) ...[
                                      const SizedBox(height: Spacing.xs),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedOriginLatLng = null;
                                            _originController.clear();
                                          });
                                          context.read<MapBloc>().add(
                                            const MapCustomOriginCleared(),
                                          );
                                        },
                                        child: Text(
                                          'Use my location',
                                          style: AppTextStyles.labelSmall
                                              .copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                      ],
                    ),
                    Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              top: 6,
                              bottom: 6,
                            ),
                            child: Container(
                              width: 2,
                              height: 20,
                              color: AppColors.border,
                            ),
                    ),
                    Row(
                      children: [
                        Container(
                                width: 32,
                                height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: AppColors.danger,
                                  size: 18,
                                ),
                        ),
                        const SizedBox(width: Spacing.md),
                        Expanded(
                          child: TextField(
                            controller: _destinationController,
                            focusNode: _destinationFocusNode,
                                  decoration: InputDecoration(
                              hintText: 'Choose destination',
                                    hintStyle: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 15,
                                    ),
                              border: InputBorder.none,
                              isDense: true,
                                    contentPadding: EdgeInsets.zero,
                            ),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                            onChanged: (q) {
                              if (q.isEmpty) {
                                      context.read<PlacesBloc>().add(
                                        const PlacesCleared(),
                                      );
                              } else {
                                      _lastSearchWasOrigin = false;
                                      context.read<PlacesBloc>().add(
                                        PlacesSearchRequested(
                                      query: q,
                                      lat: widget.userLocation?.latitude,
                                      lng: widget.userLocation?.longitude,
                                        ),
                                      );
                              }
                            },
                          ),
                        ),
                      ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    BlocBuilder<PlacesBloc, PlacesState>(
                      buildWhen: (a, b) =>
                          a.predictions != b.predictions ||
                          a.isSearching != b.isSearching,
                      builder: (context, state) {
                        if (state.isSearching) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: Spacing.md),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          );
                        }
                        if (state.predictions.isEmpty) {
                          if (widget.recentDestinations.isEmpty)
                            return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recent',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: Spacing.sm),
                              ...widget.recentDestinations.map(
                                (p) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.history,
                                    color: AppColors.textSecondary,
                                    size: 22,
                                  ),
                                  title: Text(
                                    p.name,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () {
                                    final origin = _effectiveOrigin;
                                    if (origin != null) {
                                      widget.onRequestDirections(
                                        origin,
                                        LatLng(p.lat, p.lng),
                                        p.name,
                                        _travelMode,
                                      );
                                      widget.onClose();
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.predictions.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              color: AppColors.border,
                            ),
                            itemBuilder: (context, i) {
                              final p = state.predictions[i];
                              return ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.textSecondary,
                                  size: 22,
                                ),
                                title: Text(
                                  p.mainText,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  p.secondaryText,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  _destinationController.text = p.mainText;
                                  context.read<PlacesBloc>().add(
                                    PlaceSelected(p.placeId),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: Spacing.xl),
                    Text(
                      'How do you want to get there?',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                      children: [
                        _TransportChip(
                          icon: Icons.directions_car,
                            label: 'Drive',
                          isSelected: _travelMode == TravelMode.driving,
                            onTap: () => setState(
                              () => _travelMode = TravelMode.driving,
                            ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        _TransportChip(
                          icon: Icons.directions_transit,
                          label: 'Transit',
                          isSelected: _travelMode == TravelMode.transit,
                            onTap: () => setState(
                              () => _travelMode = TravelMode.transit,
                            ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        _TransportChip(
                          icon: Icons.directions_walk,
                            label: 'Walk',
                          isSelected: _travelMode == TravelMode.walking,
                            onTap: () => setState(
                              () => _travelMode = TravelMode.walking,
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                          _TransportChip(
                            icon: Icons.directions_bike,
                            label: 'Bike',
                            isSelected: _travelMode == TravelMode.bicycling,
                            onTap: () => setState(
                              () => _travelMode = TravelMode.bicycling,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransportChip extends StatelessWidget {
  const _TransportChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          const SizedBox(width: Spacing.sm),
          Text(
            label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
          ),
        ],
        ),
      ),
    );
  }
}

class _SearchResultsOverlay extends StatelessWidget {
  const _SearchResultsOverlay({
    required this.onPlaceSelected,
    required this.onClear,
    required this.searchController,
  });

  final void Function(String placeId) onPlaceSelected;
  final VoidCallback onClear;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BlocBuilder<PlacesBloc, PlacesState>(
        builder: (context, state) {
          if (state.isSearching) {
            return const Padding(
              padding: EdgeInsets.all(Spacing.lg),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            );
          }
          if (state.error != null) {
            return Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Row(
                children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.danger,
                      size: 20,
                    ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      state.error!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.danger,
                        ),
                    ),
                  ),
                ],
              ),
            );
          }
          if (state.predictions.isEmpty) {
            return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg,
                  vertical: Spacing.xl,
                ),
              child: Center(
                child: Text(
                  'No results found. Try a different search.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: state.predictions.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final p = state.predictions[index];
                return ListTile(
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    title: Text(
                      p.mainText,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      p.secondaryText,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  onTap: () {
                    searchController.text = p.mainText;
                    onPlaceSelected(p.placeId);
                  },
                );
              },
            ),
          );
        },
        ),
      ),
    );
  }
}

class _SelectedCenterBottomSheet extends StatelessWidget {
  final LatLng? userLocation;
  final void Function(ServiceCenter center) onBook;
  final void Function(ServiceCenter center) onNavigate;
  final void Function(ServiceCenter center) onGetDirections;
  final void Function(ServiceCenter center) onRequestOnSite;
  final VoidCallback? onClose;

  const _SelectedCenterBottomSheet({
    this.userLocation,
    required this.onBook,
    required this.onNavigate,
    required this.onGetDirections,
    required this.onRequestOnSite,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceLocatorBloc, ServiceLocatorState>(
      builder: (context, state) {
        final center = _getSelectedCenter(state);
        if (center == null) return const SizedBox.shrink();

        return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(BorderRadiusValues.xl),
                topRight: Radius.circular(BorderRadiusValues.xl),
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                  const SizedBox(width: Spacing.lg),
                  Expanded(
                    child: Text(
                      'Garage details',
                      style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                    if (onClose != null)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onClose,
                        tooltip: 'Close',
                      ),
                  ],
                ),
                SizedBox(
                  height: 280,
                child: _OverviewTab(
                        center: center,
                        onBook: onBook,
                        onNavigate: onNavigate,
                        onGetDirections: onGetDirections,
                        onRequestOnSite: onRequestOnSite,
                      ),
                      ),
                    ],
          ),
        );
      },
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.center,
    required this.onBook,
    required this.onNavigate,
    required this.onGetDirections,
    required this.onRequestOnSite,
  });

  final ServiceCenter center;
  final void Function(ServiceCenter center) onBook;
  final void Function(ServiceCenter center) onNavigate;
  final void Function(ServiceCenter center) onGetDirections;
  final void Function(ServiceCenter center) onRequestOnSite;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.sm,
        Spacing.lg,
        Spacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(center.subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: center.isOpen ? AppColors.success : AppColors.danger,
                  borderRadius: BorderRadius.circular(
                    BorderRadiusValues.circular,
                  ),
                ),
                child: Text(
                  center.isOpen ? 'Open' : 'Closed',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Icon(Icons.star, size: 18, color: AppColors.warning),
              const SizedBox(width: Spacing.xs),
              Text(
                center.rating.toStringAsFixed(1),
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                '${center.reviewsCount} reviews',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Icon(Icons.straighten, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: Spacing.xs),
              Text(
                '${center.distanceMiles.toStringAsFixed(1)} mi away',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.xs,
            children: center.services
                .map(
                  (s) => ServiceTagChip(label: s),
                )
                .toList(),
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onNavigate(center),
                  icon: const Icon(Icons.directions, size: 20),
                  label: const Text('Navigate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: center.isRegistered ? () => onBook(center) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.secondary,
                  ),
                  child: const Text('Book Appointment'),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: (center.isOpen && center.onsiteServiceEnabled)
                  ? () => onRequestOnSite(center)
                  : null,
              child: const Text('Request On-site Service'),
            ),
          ),
        ],
      ),
    );
  }
}

// Directions tab removed (route is shown in-map when Navigate is tapped).

ServiceCenter? _getSelectedCenter(ServiceLocatorState state) {
  if (state.selectedCenterId == null) return null;
  return state.centers
      .where((c) => c.id == state.selectedCenterId)
      .cast<ServiceCenter?>()
      .firstOrNull;
}

extension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

class _RouteInfoCard extends StatelessWidget {
  const _RouteInfoCard({
    required this.route,
    required this.alternativesCount,
    required this.selectedIndex,
    required this.travelMode,
    required this.onAlternativeSelected,
    required this.onTravelModeChanged,
    required this.onClose,
  });

  final RouteInfo route;
  final int alternativesCount;
  final int selectedIndex;
  final TravelMode travelMode;
  final void Function(int) onAlternativeSelected;
  final void Function(TravelMode) onTravelModeChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.durationInTrafficText ?? route.durationText,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${route.distanceText} via ${route.summary}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            if (alternativesCount > 1) ...[
              const SizedBox(height: Spacing.sm),
              Row(
                children: List.generate(alternativesCount, (i) {
                  final isSelected = i == selectedIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: Spacing.xs),
                    child: ChoiceChip(
                      label: Text('Route ${i + 1}'),
                      selected: isSelected,
                      onSelected: (_) => onAlternativeSelected(i),
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: AppTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }),
              ),
            ],
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                _TravelModeChip(
                  icon: Icons.directions_car,
                  isSelected: travelMode == TravelMode.driving,
                  onTap: () => onTravelModeChanged(TravelMode.driving),
                ),
                const SizedBox(width: Spacing.xs),
                _TravelModeChip(
                  icon: Icons.directions_walk,
                  isSelected: travelMode == TravelMode.walking,
                  onTap: () => onTravelModeChanged(TravelMode.walking),
                ),
                const SizedBox(width: Spacing.xs),
                _TravelModeChip(
                  icon: Icons.directions_bike,
                  isSelected: travelMode == TravelMode.bicycling,
                  onTap: () => onTravelModeChanged(TravelMode.bicycling),
                ),
                const SizedBox(width: Spacing.xs),
                _TravelModeChip(
                  icon: Icons.directions_transit,
                  isSelected: travelMode == TravelMode.transit,
                  onTap: () => onTravelModeChanged(TravelMode.transit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TravelModeChip extends StatelessWidget {
  const _TravelModeChip({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
