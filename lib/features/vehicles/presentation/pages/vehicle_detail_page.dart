library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/service_locator.dart';
import '../../../maintenance/presentation/bloc/maintenance_bloc.dart';
import '../../../maintenance/presentation/bloc/maintenance_event.dart';
import '../../../maintenance/presentation/bloc/maintenance_state.dart';
import '../../domain/entities/vehicle.dart';
import '../bloc/vehicles_bloc.dart';
import '../bloc/vehicles_event.dart';
import '../bloc/vehicles_state.dart';

class VehicleDetailPage extends StatelessWidget {
  const VehicleDetailPage({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<VehiclesBloc>()..add(VehicleDetailRequested(vehicleId)),
        ),
        BlocProvider(
          create: (_) => getIt<MaintenanceBloc>()..add(const MaintenanceLoadRequested()),
        ),
      ],
      child: _VehicleDetailView(vehicleId: vehicleId),
    );
  }
}

class _VehicleDetailView extends StatelessWidget {
  const _VehicleDetailView({required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehiclesBloc, VehiclesState>(
      listenWhen: (prev, curr) => curr is VehicleDeleted || curr is VehiclesFailure,
      listener: (context, state) {
        if (state is VehicleDeleted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle removed.'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: BlocBuilder<VehiclesBloc, VehiclesState>(
          builder: (context, state) {
            if (state is! VehicleDetailLoaded) {
              return Text(
                'Vehicle Details',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              );
            }
            final v = state.vehicle;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  v.displayName,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  v.plateNumber,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: BlocBuilder<VehiclesBloc, VehiclesState>(
        builder: (context, state) {
          if (state is VehiclesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VehiclesFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                    const SizedBox(height: Spacing.md),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: Spacing.lg),
                    TextButton(
                      onPressed: () => context.read<VehiclesBloc>().add(VehicleDetailRequested(vehicleId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is! VehicleDetailLoaded) {
            return const SizedBox.shrink();
          }
          final vehicle = state.vehicle;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ImagePlaceholder(),
                const SizedBox(height: Spacing.lg),
                _OverallHealthCard(vehicleId: vehicle.id),
                const SizedBox(height: Spacing.lg),
                _VehicleInformationCard(vehicle: vehicle),
                const SizedBox(height: Spacing.lg),
                _DocumentsCard(
                  insuranceDocumentUrl: vehicle.insuranceDocumentUrl,
                  insuranceExpiresAt: vehicle.insuranceExpiresAt,
                  registrationDocumentUrl: vehicle.registrationDocumentUrl,
                  registrationExpiresAt: vehicle.registrationExpiresAt,
                ),
                const SizedBox(height: Spacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).pushNamed(
                        '/vehicles/edit',
                        arguments: vehicle,
                      );
                      if (context.mounted) {
                        context.read<VehiclesBloc>().add(VehicleDetailRequested(vehicleId));
                      }
                    },
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    label: const Text('Edit Vehicle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmRemove(context, vehicle),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text('Remove Vehicle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.bottomNavHeight + Spacing.lg),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _VehicleDetailBottomNav(),
    ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, Vehicle vehicle) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove vehicle?'),
        content: Text(
          '${vehicle.displayName} will be removed. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Remove', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<VehiclesBloc>().add(VehicleDeleteRequested(vehicle.id));
    }
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
      ),
      child: Icon(Icons.directions_car_outlined, size: 64, color: AppColors.textSecondary),
    );
  }
}

class _OverallHealthCard extends StatelessWidget {
  const _OverallHealthCard({required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaintenanceBloc, MaintenanceState>(
      builder: (context, mState) {
        final enabledCount = mState.upcoming.where((u) => u.vehicleId == vehicleId && u.reminderEnabled).length;
        final pct = (85 - enabledCount * 5).clamp(0, 100);
        final color = pct >= 75 ? AppColors.success : (pct >= 45 ? AppColors.pending : AppColors.danger);

        return _OverallHealthCardBody(percentage: pct, color: color);
      },
    );
  }
}

class _OverallHealthCardBody extends StatelessWidget {
  const _OverallHealthCardBody({required this.percentage, required this.color});
  final int percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Overall Health',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '$percentage%',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleInformationCard extends StatelessWidget {
  const _VehicleInformationCard({required this.vehicle});

  final Vehicle vehicle;

  static String _formatMileage(int n) {
    if (n < 1000) return n.toString();
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final mileageStr = vehicle.mileage != null ? '${_formatMileage(vehicle.mileage!)} miles' : '—';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Information',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: Spacing.md),
          _InfoRow(icon: Icons.directions_car_outlined, label: 'Make & Model', value: '${vehicle.make} ${vehicle.model}'),
          _InfoRow(icon: Icons.calendar_today_outlined, label: 'Year', value: vehicle.year.toString()),
          _InfoRow(icon: Icons.description_outlined, label: 'VIN', value: vehicle.vin ?? '—'),
          _InfoRow(icon: Icons.speed_outlined, label: 'Mileage', value: mileageStr),
          _InfoRow(icon: Icons.local_gas_station_outlined, label: 'Fuel Type', value: vehicle.fuelType ?? '—'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsCard extends StatelessWidget {
  const _DocumentsCard({
    this.insuranceDocumentUrl,
    this.insuranceExpiresAt,
    this.registrationDocumentUrl,
    this.registrationExpiresAt,
  });

  final String? insuranceDocumentUrl;
  final DateTime? insuranceExpiresAt;
  final String? registrationDocumentUrl;
  final DateTime? registrationExpiresAt;

  static String _formatDate(DateTime d) {
    const months = 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec';
    return '${months.split(',')[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final insuranceText = insuranceExpiresAt != null
        ? 'Active - Expires ${_formatDate(insuranceExpiresAt!)}'
        : '—';
    final registrationText = registrationExpiresAt != null
        ? 'Valid - Expires ${_formatDate(registrationExpiresAt!)}'
        : '—';

    final hasInsuranceDoc = (insuranceDocumentUrl ?? '').trim().isNotEmpty;
    final hasRegistrationDoc = (registrationDocumentUrl ?? '').trim().isNotEmpty;
    final hasAnyDoc = hasInsuranceDoc || hasRegistrationDoc;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documents',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Insurance', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                    Text(insuranceText, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Icon(Icons.description_outlined, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Registration', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                    Text(registrationText, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: hasAnyDoc
                  ? () => _showDocumentsSheet(
                        context,
                        insuranceUrl: hasInsuranceDoc ? insuranceDocumentUrl!.trim() : null,
                        registrationUrl:
                            hasRegistrationDoc ? registrationDocumentUrl!.trim() : null,
                      )
                  : null,
              icon: const Icon(Icons.folder_open_outlined, size: 18),
              label: const Text('View Documents'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary),
                padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _showDocumentsSheet(
    BuildContext context, {
    required String? insuranceUrl,
    required String? registrationUrl,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        Future<void> open(String url) async {
          final uri = Uri.tryParse(url);
          if (uri == null) return;
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Documents',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                if (insuranceUrl != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.shield_outlined),
                    title: const Text('Insurance Document'),
                    subtitle: Text(
                      insuranceUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => open(insuranceUrl),
                  ),
                if (registrationUrl != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Registration Document'),
                    subtitle: Text(
                      registrationUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => open(registrationUrl),
                  ),
                if (insuranceUrl == null && registrationUrl == null)
                  Text(
                    'No documents available.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VehicleDetailBottomNav extends StatelessWidget {
  const _VehicleDetailBottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: AppColors.surface,
      elevation: 0,
      child: SizedBox(
        height: Dimensions.bottomNavHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(icon: Icons.home_filled, label: 'Home', onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/driver-dashboard', (r) => r.isFirst)),
              _NavItem(icon: Icons.directions_car_filled, label: 'Vehicle', isActive: true),
              _NavItem(icon: Icons.build_outlined, label: 'Service', onTap: () => Navigator.of(context).pushNamed('/services')),
              _NavItem(icon: Icons.people_alt_outlined, label: 'Community', onTap: () => Navigator.of(context).pushNamed('/community')),
              _NavItem(
                icon: Icons.menu_book_outlined,
                label: 'Education',
                onTap: () => Navigator.of(context).pushNamed('/education'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
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
    final color = isActive ? AppColors.textPrimary : AppColors.textSecondary;
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
