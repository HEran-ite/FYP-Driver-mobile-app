import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../injection/service_locator.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../appointments/presentation/bloc/appointments_bloc.dart';
import '../../../appointments/presentation/bloc/appointments_event.dart';
import '../../../appointments/presentation/bloc/appointments_state.dart';
import '../../domain/entities/service_center.dart';
import '../../../../core/widgets/nav_app_bar.dart';

class AppointmentsListPage extends StatefulWidget {
  const AppointmentsListPage({
    super.key,
    this.centers = const [],
  });

  final List<ServiceCenter> centers;

  @override
  State<AppointmentsListPage> createState() => _AppointmentsListPageState();
}

class _AppointmentsListPageState extends State<AppointmentsListPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AppointmentsBloc>()..add(const AppointmentsLoadRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: const AppDrawer(currentRoute: '/services'),
        appBar: const NavAppBar(title: 'CarCare', notificationCount: 3),
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

              final upcoming = appointments
                  .where((a) =>
                      a.status != AppointmentStatus.rejected &&
                      a.status != AppointmentStatus.completed)
                  .toList();

              if (upcoming.isEmpty) {
                return Center(
                  child: Text(
                    'No appointments found',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.lg,
                      Spacing.md,
                      Spacing.lg,
                      Spacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appointments',
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          'View and manage your bookings',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.lg,
                        vertical: Spacing.lg,
                      ),
                      itemCount: upcoming.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: Spacing.sm),
                          child: _AppointmentCardFromEntity(
                            appointment: upcoming[index],
                            centers: widget.centers,
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
                  appointment.serviceDescription.isNotEmpty
                      ? appointment.serviceDescription
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
              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: Spacing.xs),
              Text(dateStr, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: Spacing.md),
              const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: Spacing.xs),
              Text(timeStr, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: Spacing.md),
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
          AppointmentRescheduleRequested(id: appointment.id, scheduledAt: scheduledAt),
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
      context.read<AppointmentsBloc>().add(AppointmentCancelRequested(appointment.id));
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
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.rejected:
        return AppColors.danger;
      case AppointmentStatus.inService:
        return AppColors.info;
      case AppointmentStatus.cancelled:
        return AppColors.textSecondary;
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
                onTap: () {},
              ),
              _ServiceBottomNavItem(
                icon: Icons.menu_book_outlined,
                label: 'Edu',
                onTap: () {},
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

