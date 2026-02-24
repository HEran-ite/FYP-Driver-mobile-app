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
import '../bloc/service_locator_bloc.dart';
import '../bloc/service_locator_event.dart';
import '../bloc/service_locator_state.dart';

class ServiceLocatorPage extends StatelessWidget {
  const ServiceLocatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<ServiceLocatorBloc>()..add(const InitializeServiceLocator()),
        ),
        BlocProvider(
          create: (_) =>
              getIt<AppointmentsBloc>()..add(const AppointmentsLoadRequested()),
        ),
      ],
      child: const _ServiceLocatorView(),
    );
  }
}

class _ServiceLocatorView extends StatelessWidget {
  const _ServiceLocatorView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: '/services'),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: BlocBuilder<ServiceLocatorBloc, ServiceLocatorState>(
          builder: (context, state) {
            if (state.isLoading && state.centers.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failureMessage != null && state.centers.isEmpty) {
              return _ServiceErrorView(
                message: state.failureMessage!,
                onRetry: () => context
                    .read<ServiceLocatorBloc>()
                    .add(const LoadNearbyGarages()),
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
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    'Find nearby garages and book service',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: Spacing.lg),
                  _MapPreviewCard(
                    onTap: () {
                      Navigator.of(context).pushNamed('/services/map');
                    },
                  ),
                  const SizedBox(height: Spacing.lg),
                  const _QuickHelpRow(),
                  const SizedBox(height: Spacing.lg),
                  const _RecentAppointmentsSection(),
                  const SizedBox(height: Spacing.lg),
                  _NearbyCentersSection(centers: state.centers),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const _ServiceBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        onPressed: () {},
        child: const ImageIcon(AssetImage('assets/images/ai_icon.png')),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'CarCare',
        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      centerTitle: false,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: Spacing.md),
      ],
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

class _RecentAppointmentsSection extends StatelessWidget {
  const _RecentAppointmentsSection();

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
        if (state is AppointmentsFailure) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
            child: Text(
              state.message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
            ),
          );
        }
        final appointments = state is AppointmentsLoaded
            ? state.appointments
            : state is AppointmentActionSuccess
                ? [state.appointment]
                : <Appointment>[];
        if (appointments.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Appointments',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Spacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(BorderRadiusValues.xl),
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
                    'No appointments yet',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Appointments',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.md),
            ...appointments.take(5).map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: _AppointmentCardFromEntity(appointment: a),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _AppointmentCardFromEntity extends StatelessWidget {
  const _AppointmentCardFromEntity({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel(appointment.status);
    final statusColor = _statusColor(appointment.status);
    final dateStr = _formatDate(appointment.scheduledAt);
    final timeStr = _formatTime(appointment.scheduledAt);

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
                  borderRadius:
                      BorderRadius.circular(BorderRadiusValues.circular),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'Garage ID: ${appointment.garageId}',
            style: AppTextStyles.bodySmall,
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
              Text(dateStr, style: AppTextStyles.bodySmall),
              const SizedBox(width: Spacing.md),
              Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: Spacing.xs),
              Text(timeStr, style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.approved:
        return 'Approved';
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

  Color _statusColor(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending:
        return AppColors.pending;
      case AppointmentStatus.approved:
        return AppColors.success;
      case AppointmentStatus.rejected:
        return AppColors.danger;
      case AppointmentStatus.inService:
        return AppColors.info;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
            ),
            child: Icon(
              Icons.garage_outlined,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  center.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  center.subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: AppColors.warning),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      center.rating.toStringAsFixed(1),
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(width: Spacing.md),
                    Text(
                      '${center.distanceMiles.toStringAsFixed(1)} mi away',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickHelpRow extends StatelessWidget {
  const _QuickHelpRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _QuickHelpCard(
            icon: Icons.warning_amber_outlined,
            label: 'Emergency Help',
          ),
        ),
        SizedBox(width: Spacing.md),
        Expanded(
          child: _QuickHelpCard(
            icon: Icons.phone_in_talk_outlined,
            label: 'Call Roadside',
          ),
        ),
      ],
    );
  }
}

class _QuickHelpCard extends StatelessWidget {
  const _QuickHelpCard({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: label == 'Emergency Help'
                ? AppColors.danger
                : AppColors.success,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
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
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    'Map View',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: Spacing.lg,
              bottom: Spacing.lg,
              child: FloatingActionButton.small(
                heroTag: 'mapPreviewFab',
                backgroundColor: AppColors.primary,
                onPressed: onTap,
                child: Icon(Icons.near_me_outlined, color: AppColors.secondary),
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
            children: const [
              _ServiceBottomNavItem(
                icon: Icons.home_filled,
                label: 'Home',
              ),
              _ServiceBottomNavItem(
                icon: Icons.directions_car_filled,
                label: 'Vehicles',
              ),
              _ServiceBottomNavItem(
                icon: Icons.handyman_outlined,
                label: 'Service',
                isActive: true,
              ),
              _ServiceBottomNavItem(
                icon: Icons.people_alt_outlined,
                label: 'Community',
              ),
              _ServiceBottomNavItem(
                icon: Icons.menu_book_outlined,
                label: 'Edu',
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
  });

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.black : AppColors.textSecondary;
    return InkWell(
      onTap: null,
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

