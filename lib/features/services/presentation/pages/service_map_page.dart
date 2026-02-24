import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/service_center.dart';
import '../../../appointments/presentation/bloc/appointments_bloc.dart';
import '../../../appointments/presentation/bloc/appointments_event.dart';
import '../../../appointments/presentation/bloc/appointments_state.dart';
import '../bloc/service_locator_bloc.dart';
import '../bloc/service_locator_event.dart';
import '../bloc/service_locator_state.dart';

/// Default fallback when location is unavailable (San Francisco).
const double _defaultLat = 37.7749;
const double _defaultLng = -122.4194;

class ServiceMapPage extends StatefulWidget {
  final String? initialCenterId;

  const ServiceMapPage({super.key, this.initialCenterId});

  @override
  State<ServiceMapPage> createState() => _ServiceMapPageState();
}

class _ServiceMapPageState extends State<ServiceMapPage> {
  GoogleMapController? _mapController;
  LatLng? _userLocation;
  bool _locationResolved = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<ServiceLocatorBloc>();
    if (widget.initialCenterId != null) {
      bloc.add(SelectServiceCenter(widget.initialCenterId!));
    }
    _resolveUserLocation();
  }

  Future<void> _resolveUserLocation() async {
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      if (mounted) setState(() => _locationResolved = true);
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _locationResolved = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _locationResolved = true);
    }
  }

  LatLng _initialTarget(ServiceLocatorState state) {
    if (_userLocation != null) return _userLocation!;
    final center = _getSelectedCenter(state);
    if (center != null) return LatLng(center.latitude, center.longitude);
    if (state.centers.isNotEmpty) {
      final c = state.centers.first;
      return LatLng(c.latitude, c.longitude);
    }
    return const LatLng(_defaultLat, _defaultLng);
  }

  void _centerOnUserLocation() {
    if (_userLocation == null) return;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_userLocation!, 14),
    );
  }

  void _onBookAppointment(ServiceCenter center) {
    _showBookDialog(context, center);
  }

  Future<void> _showBookDialog(BuildContext context, ServiceCenter center) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null || !context.mounted) return;
    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final descriptionController = TextEditingController(
      text: center.services.isNotEmpty ? center.services.first : 'General service',
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Book Appointment'),
        content: TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Service description',
            hintText: 'e.g. Oil change, brake check',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Book'),
          ),
        ],
      ),
    );
    final serviceDescription = descriptionController.text.trim().isEmpty
        ? 'Service'
        : descriptionController.text.trim();
    descriptionController.dispose();
    if (confirmed != true || !context.mounted) return;
    context.read<AppointmentsBloc>().add(AppointmentBookRequested(
          garageId: center.id,
          scheduledAt: scheduledAt,
          serviceDescription: serviceDescription,
        ));
    context.read<AppointmentsBloc>().add(const AppointmentsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppointmentsBloc, AppointmentsState>(
      listener: (context, state) {
        if (state is AppointmentActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment booked successfully')),
          );
        }
        if (state is AppointmentsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Service Centers Map',
          style: AppTextStyles.titleMedium
              .copyWith(fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocBuilder<ServiceLocatorBloc, ServiceLocatorState>(
        builder: (context, state) {
          if (state.isLoading || state.centers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!_locationResolved) {
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

          final markers = _buildMarkers(state);
          final initialTarget = _initialTarget(state);

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialTarget,
                  zoom: 13,
                ),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                onCameraIdle: () {},
              ),
              Positioned(
                right: Spacing.md,
                bottom: 200,
                child: FloatingActionButton.small(
                  heroTag: 'centerOnMe',
                  backgroundColor: Colors.white,
                  onPressed: _userLocation != null ? _centerOnUserLocation : null,
                  child: Icon(
                    Icons.my_location,
                    color: _userLocation != null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _SelectedCenterBottomSheet(
                  onBook: _onBookAppointment,
                  onRequestOnSite: () {},
                ),
              ),
            ],
          );
        },
      ),
    ),
    );
  }

  Set<Marker> _buildMarkers(ServiceLocatorState state) {
    final bloc = context.read<ServiceLocatorBloc>();
    return state.centers.map((center) {
      final hue = center.isRegistered
          ? BitmapDescriptor.hueAzure
          : BitmapDescriptor.hueOrange;

      return Marker(
        markerId: MarkerId(center.id),
        position: LatLng(center.latitude, center.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        onTap: () {
          bloc.add(SelectServiceCenter(center.id));
          _focusOnCenter(center);
        },
      );
    }).toSet();
  }

  void _focusOnCenter(ServiceCenter center) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(center.latitude, center.longitude),
      ),
    );
  }
}

class _SelectedCenterBottomSheet extends StatelessWidget {
  final void Function(ServiceCenter center) onBook;
  final VoidCallback onRequestOnSite;

  const _SelectedCenterBottomSheet({
    required this.onBook,
    required this.onRequestOnSite,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceLocatorBloc, ServiceLocatorState>(
      builder: (context, state) {
        final center = _getSelectedCenter(state);
        if (center == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(Spacing.lg),
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
                        Text(
                          center.subtitle,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: center.isOpen
                          ? AppColors.success
                          : AppColors.danger,
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
              const SizedBox(height: Spacing.md),
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.xs,
                children: center.services
                    .map(
                      (s) => Chip(
                        label: Text(
                          s,
                          style: AppTextStyles.labelSmall,
                        ),
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.border),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: center.isRegistered
                          ? () => onBook(center)
                          : null,
                      child: const Text('Book Appointment'),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: center.isRegistered ? onRequestOnSite : null,
                      child: const Text('Request On-site Service'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

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

