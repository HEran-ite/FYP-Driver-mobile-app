import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/nav_app_bar.dart';
import '../../../../injection/service_locator.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../appointments/presentation/bloc/appointments_bloc.dart';
import '../../../appointments/presentation/bloc/appointments_event.dart';
import '../../../appointments/presentation/bloc/appointments_state.dart';
import '../../domain/entities/service_center.dart';
import '../bloc/service_locator_bloc.dart';
import '../bloc/service_locator_event.dart';
import '../bloc/service_locator_state.dart';
import 'book_service_wizard_page.dart';
import '../widgets/service_tag_chip.dart';
import '../widgets/service_text_formatter.dart';

class ServiceLocatorPage extends StatelessWidget {
  const ServiceLocatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ServiceLocatorBloc>()),
        BlocProvider(
          create: (_) =>
              getIt<AppointmentsBloc>()..add(const AppointmentsLoadRequested()),
        ),
      ],
      child: const _ServiceLocatorView(),
    );
  }
}

class _ServiceLocatorView extends StatefulWidget {
  const _ServiceLocatorView();

  @override
  State<_ServiceLocatorView> createState() => _ServiceLocatorViewState();
}

class _ServiceLocatorViewState extends State<_ServiceLocatorView> {
  static const double _fallbackLat = 0.0;
  static const double _fallbackLng = 0.0;

  @override
  void initState() {
    super.initState();
    _loadNearbyWithLocation();
  }

  Future<void> _loadNearbyWithLocation() async {
    double lat = _fallbackLat;
    double lng = _fallbackLng;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Keep fallback coords; backend requires params.
        throw Exception('Location services are disabled');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      lat = pos.latitude;
      lng = pos.longitude;
    } catch (e) {
      // Show a helpful message but still load with fallback coordinates to avoid backend 400s.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e. Showing results based on default location.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (!mounted) return;
    context.read<ServiceLocatorBloc>().add(
      LoadNearbyGarages(latitude: lat, longitude: lng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: '/services'),
      appBar: const NavAppBar(title: 'CarCare', notificationCount: 3),
      body: SafeArea(
        child: BlocConsumer<AppointmentsBloc, AppointmentsState>(
          listenWhen: (prev, curr) =>
              curr is AppointmentActionSuccess || curr is AppointmentsFailure,
          listener: (context, state) {
            if (state is AppointmentActionSuccess) {
              context.read<AppointmentsBloc>().add(
                const AppointmentsLoadRequested(),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Appointment updated.'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            if (state is AppointmentsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, _) =>
              BlocBuilder<ServiceLocatorBloc, ServiceLocatorState>(
                builder: (context, state) {
                  if (state.isLoading && state.centers.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.failureMessage != null && state.centers.isEmpty) {
                    return _ServiceErrorView(
                      message: state.failureMessage!,
                      onRetry: _loadNearbyWithLocation,
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.lg,
                      vertical: Spacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Centers',
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          'Find nearby garages and book service',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: Spacing.lg),
                        _MapPreviewCard(
                          onTap: () {
                            Navigator.of(context).pushNamed('/services/map');
                          },
                        ),
                        const SizedBox(height: Spacing.lg),
                        _UpcomingAppointmentsSection(centers: state.centers),
                        const SizedBox(height: Spacing.lg),
                        _NearbyCentersSection(centers: state.centers),
                      ],
                    ),
                  );
                },
              ),
        ),
      ),
      bottomNavigationBar: const _ServiceBottomNavBar(),
    );
  }
}

class _ServiceErrorView extends StatelessWidget {
  const _ServiceErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: Spacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.secondary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingAppointmentsSection extends StatelessWidget {
  const _UpcomingAppointmentsSection({required this.centers});

  final List<ServiceCenter> centers;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentsBloc, AppointmentsState>(
      builder: (context, state) {
        if (state is AppointmentsLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.md),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        List<Appointment> appointments;
        if (state is AppointmentsLoaded) {
          appointments = state.appointments;
        } else if (state is AppointmentActionSuccess) {
          appointments = [state.appointment];
        } else {
          appointments = <Appointment>[];
        }
        final upcoming = appointments
            .where(
              (a) =>
                  a.status != AppointmentStatus.cancelled &&
                  a.status != AppointmentStatus.rejected &&
                  a.status != AppointmentStatus.completed,
            )
            .toList();

        final top3 = upcoming.take(3).toList();
        final hasMore = upcoming.length > 3;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Upcoming Appointments',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final appointmentsBloc = context.read<AppointmentsBloc>();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => BlocProvider.value(
                          value: appointmentsBloc,
                          child: AllUpcomingAppointmentsPage(centers: centers),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'View All',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: hasMore
                          ? AppColors.textSecondary
                          : AppColors.textSecondary.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            if (upcoming.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'No upcoming appointments',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ...top3.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.sm),
                  child: _AppointmentCardFromEntity(
                    appointment: a,
                    centers: centers,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class AllUpcomingAppointmentsPage extends StatelessWidget {
  const AllUpcomingAppointmentsPage({super.key, required this.centers});

  final List<ServiceCenter> centers;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AppointmentsBloc>()..add(const AppointmentsLoadRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Appointments',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<AppointmentsBloc, AppointmentsState>(
            builder: (context, state) {
              List<Appointment> appointments;
              if (state is AppointmentsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AppointmentsLoaded) {
                appointments = state.appointments;
              } else if (state is AppointmentActionSuccess) {
                appointments = [state.appointment];
              } else {
                appointments = <Appointment>[];
              }

              final allAppointments = appointments;

              if (allAppointments.isEmpty) {
                return Center(
                  child: Text(
                    'No appointments yet',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg,
                  vertical: Spacing.lg,
                ),
                itemCount: allAppointments.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: _AppointmentCardFromEntity(
                      appointment: allAppointments[index],
                      centers: centers,
                    ),
                  );
                },
              );
            },
          ),
        ),
        bottomNavigationBar: const _ServiceBottomNavBar(),
      ),
    );
  }
}

class _AppointmentCardFromEntity extends StatelessWidget {
  const _AppointmentCardFromEntity({
    required this.appointment,
    required this.centers,
  });

  final Appointment appointment;
  final List<ServiceCenter> centers;

  String get _garageName {
    try {
      return centers.firstWhere((c) => c.id == appointment.garageId).name;
    } catch (_) {
      return 'Garage';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel(appointment.status);
    final statusColor = _statusColor(appointment.status);
    final dateStr = _formatDate(appointment.scheduledAt);
    final timeStr = _formatTime(appointment.scheduledAt);

    final garageName = appointment.garageName ?? _garageName;
    final carName = appointment.vehicleName ?? '—';

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  appointment.serviceSummary.isNotEmpty
                      ? formatServiceLine(appointment.serviceSummary)
                      : 'Service',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(
                    BorderRadiusValues.circular,
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _statusTextColor(appointment.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'Garage: $garageName',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'Car: $carName',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                dateStr,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: Spacing.xs),
              Text(
                timeStr,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          if (appointment.status == AppointmentStatus.completed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _onRateGarage(context),
                icon: const Icon(Icons.star_rounded),
                label: const Text('Rate Garage'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _onReschedule(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                    ),
                    child: const Text('Reschedule'),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _onCancel(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _onRateGarage(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final reviewCtrl = TextEditingController();
    int stars = 5;
    final submit = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Rate Garage'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('How was your service experience?'),
                  const SizedBox(height: Spacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(5, (i) {
                      final on = i < stars;
                      return IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() => stars = i + 1),
                        icon: Icon(
                          on ? Icons.star_rounded : Icons.star_border_rounded,
                          color: on
                              ? AppColors.warning
                              : AppColors.textSecondary,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: Spacing.sm),
                  TextField(
                    controller: reviewCtrl,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Write optional feedback',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
    if (submit != true) return;
    try {
      await getIt<ApiClient>().dio.post(
        ApiEndpoints.driverAppointmentReview(appointment.id),
        data: {
          'rating': stars,
          if (reviewCtrl.text.trim().isNotEmpty)
            'comment': reviewCtrl.text.trim(),
        },
      );
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Thanks! Your rating was submitted.'),
          backgroundColor: AppColors.success,
        ),
      );
      if (!context.mounted) return;
      try {
        context.read<ServiceLocatorBloc>().add(
          const RefreshNearbyGaragesRequested(),
        );
      } catch (_) {}
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && data['error'] != null)
          ? data['error'].toString()
          : 'Unable to submit rating';
      messenger.showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _onReschedule(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: appointment.scheduledAt.isAfter(DateTime.now())
          ? appointment.scheduledAt
          : DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(appointment.scheduledAt),
    );
    if (time == null || !context.mounted) return;
    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    context.read<AppointmentsBloc>().add(
      AppointmentRescheduleRequested(
        id: appointment.id,
        scheduledAt: scheduledAt,
      ),
    );
  }

  Future<void> _onCancel(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel appointment?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Yes', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<AppointmentsBloc>().add(
        AppointmentCancelRequested(appointment.id),
      );
    }
  }

  String _statusLabel(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.approved:
        return 'Confirmed';
      case AppointmentStatus.rejected:
        return 'Rejected';
      case AppointmentStatus.inService:
        return 'In Service';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _statusTextColor(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending:
        return AppColors.textPrimary;
      default:
        return AppColors.textOnPrimary;
    }
  }

  Color _statusColor(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending:
        return AppColors.pending;
      case AppointmentStatus.approved:
        return AppColors.success;
      case AppointmentStatus.rejected:
        return AppColors.danger;
      case AppointmentStatus.inService:
        return AppColors.pending;
      case AppointmentStatus.completed:
        return AppColors.infoStatus;
      case AppointmentStatus.cancelled:
        return AppColors.danger;
    }
  }

  String _formatDate(DateTime d) {
    const months = 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec';
    final parts = months.split(',');
    final month = parts[d.month - 1];
    return '$month ${d.day}, ${d.year}';
  }

  String _formatTime(DateTime d) {
    final h = d.hour;
    final m = d.minute;
    final am = h < 12;
    final hour = am ? (h == 0 ? 12 : h) : (h == 12 ? 12 : h - 12);
    return '${hour.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} ${am ? 'AM' : 'PM'}';
  }
}

class _NearbyCentersSection extends StatelessWidget {
  const _NearbyCentersSection({required this.centers});

  final List<ServiceCenter> centers;

  @override
  Widget build(BuildContext context) {
    if (centers.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nearby Service Centers',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'No nearby garages found.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nearby Service Centers',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        ...centers.map(
          (center) => Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: _NearbyCenterCard(center: center),
          ),
        ),
      ],
    );
  }
}

class _NearbyCenterCard extends StatelessWidget {
  const _NearbyCenterCard({required this.center});

  final ServiceCenter center;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      center.isOpen ? 'Open' : 'Closed',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: center.isOpen
                            ? AppColors.success
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: AppColors.warning),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          center.rating.toStringAsFixed(1),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          ' (${center.reviewsCount})',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: Spacing.md),
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          '${center.distanceMiles.toStringAsFixed(1)} mi',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (center.services.isNotEmpty) ...[
                      const SizedBox(height: Spacing.sm),
                      Wrap(
                        spacing: Spacing.xs,
                        runSpacing: Spacing.xs,
                        children: center.services.take(4).map((s) {
                          return ServiceTagChip(label: s.name);
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => BookServiceWizardPage(center: center),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: const Text('Book'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _callCenter(context, center.phone),
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/services/map',
                      arguments: {'centerId': center.id, 'autoNavigate': true},
                    );
                  },
                  icon: const Icon(Icons.near_me_outlined, size: 18),
                  label: const Text('Route'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _callCenter(BuildContext context, String rawPhone) async {
    final messenger = ScaffoldMessenger.of(context);
    final phone = rawPhone.trim();
    if (phone.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('No phone number available for this garage.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    final ok = await canLaunchUrl(uri);
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Calling is not supported on this device.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 16,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 40,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    'Map View',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: Spacing.lg,
              bottom: Spacing.lg,
              child: Material(
                elevation: 2,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onTap,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.near_me_outlined,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceBottomNavBar extends StatelessWidget {
  const _ServiceBottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      child: SizedBox(
        height: Dimensions.bottomNavHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ServiceBottomNavItem(
                icon: Icons.home_filled,
                label: 'Home',
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  '/driver-dashboard',
                  (route) => route.isFirst,
                ),
              ),
              _ServiceBottomNavItem(
                icon: Icons.directions_car_filled,
                label: 'Vehicles',
                onTap: () => Navigator.of(context).pushNamed('/vehicles'),
              ),
              const _ServiceBottomNavItem(
                icon: Icons.handyman_outlined,
                label: 'Service',
                isActive: true,
              ),
              _ServiceBottomNavItem(
                icon: Icons.people_alt_outlined,
                label: 'Community',
                onTap: () => Navigator.of(context).pushNamed('/community'),
              ),
              _ServiceBottomNavItem(
                icon: Icons.menu_book_outlined,
                label: 'Edu',
                onTap: () => Navigator.of(context).pushNamed('/education'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceBottomNavItem extends StatelessWidget {
  const _ServiceBottomNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.black : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: Spacing.xs),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
