library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../injection/service_locator.dart';
import '../../domain/entities/vehicle.dart';
import '../bloc/vehicles_bloc.dart';
import '../bloc/vehicles_event.dart';
import '../bloc/vehicles_state.dart';
import 'vehicle_detail_page.dart';

class VehiclesListPage extends StatelessWidget {
  const VehiclesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VehiclesBloc>()..add(const VehiclesLoadRequested()),
      child: const _VehiclesListView(),
    );
  }
}

class _VehiclesListView extends StatelessWidget {
  const _VehiclesListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: '/vehicles'),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: BlocBuilder<VehiclesBloc, VehiclesState>(
          builder: (context, state) {
            if (state is VehiclesLoading && state is! VehiclesLoaded) {
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
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: Spacing.lg),
                      TextButton(
                        onPressed: () => context.read<VehiclesBloc>().add(const VehiclesLoadRequested()),
                        child: Text(
                          'Retry',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            final vehicles = state is VehiclesLoaded ? state.vehicles : <Vehicle>[];
            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: Spacing.lg,
                right: Spacing.lg,
                top: Spacing.lg,
                bottom: Spacing.lg + Dimensions.bottomNavHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Vehicles',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    'Manage your vehicles',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: Spacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await Navigator.of(context).pushNamed('/vehicles/add');
                        if (context.mounted) {
                          context.read<VehiclesBloc>().add(const VehiclesLoadRequested());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                      ),
                      child: const Text('Create'),
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  if (vehicles.isEmpty)
                    _EmptyVehiclesCard()
                  else
                    ...vehicles.map(
                      (v) => Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.sm),
                        child: _VehicleListCard(
                          vehicle: v,
                          onTap: () async {
                            final result = await Navigator.of(context).push<bool>(
                              MaterialPageRoute<bool>(
                                builder: (context) => VehicleDetailPage(vehicleId: v.id),
                              ),
                            );
                            if (context.mounted && result == true) {
                              context.read<VehiclesBloc>().add(const VehiclesLoadRequested());
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const _VehiclesListBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed('/vehicles/add');
          if (context.mounted) {
            context.read<VehiclesBloc>().add(const VehiclesLoadRequested());
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.secondary),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.textPrimary),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: null,
    );
  }
}

class _VehicleListCard extends StatelessWidget {
  const _VehicleListCard({required this.vehicle, required this.onTap});

  final Vehicle vehicle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = vehicle.status != VehicleStatus.pending;
    final statusColor = isActive ? AppColors.success : AppColors.pending;
    final statusText = isActive ? 'Active' : 'Pending';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
              ),
              child: Icon(Icons.directions_car_outlined, color: AppColors.secondary, size: 28),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.displayName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: Spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(BorderRadiusValues.sm),
                    ),
                    child: Text(
                      statusText,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isActive ? AppColors.textOnPrimary : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _VehiclesListBottomNavBar extends StatelessWidget {
  const _VehiclesListBottomNavBar();

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
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _VehiclesListBottomNavItem(
                icon: Icons.home_filled,
                label: 'Home',
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  '/driver-dashboard',
                  (route) => route.isFirst,
                ),
              ),
              _VehiclesListBottomNavItem(
                icon: Icons.directions_car_filled,
                label: 'Vehicles',
                isActive: true,
                onTap: () {},
              ),
              _VehiclesListBottomNavItem(
                icon: Icons.handyman_outlined,
                label: 'Service',
                onTap: () => Navigator.of(context).pushNamed('/services'),
              ),
              const _VehiclesListBottomNavItem(
                icon: Icons.people_alt_outlined,
                label: 'Community',
              ),
              const _VehiclesListBottomNavItem(
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

class _VehiclesListBottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _VehiclesListBottomNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

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

class _EmptyVehiclesCard extends StatelessWidget {
  const _EmptyVehiclesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          "You don't have any vehicles yet. Add a new vehicle to get started.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
