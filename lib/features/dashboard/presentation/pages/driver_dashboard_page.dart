import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/nav_app_bar.dart';
import '../../../../injection/service_locator.dart';
import '../../../vehicles/domain/entities/vehicle.dart';
import '../../../vehicles/presentation/bloc/vehicles_bloc.dart';
import '../../../vehicles/presentation/bloc/vehicles_event.dart';
import '../../../vehicles/presentation/bloc/vehicles_state.dart';

class DriverDashboardPage extends StatelessWidget {
  const DriverDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: '/driver-dashboard'),
      appBar: const NavAppBar(title: 'CarCare', notificationCount: 3),
      body: SafeArea(
        child: BlocProvider(
          create: (_) =>
              getIt<VehiclesBloc>()..add(const VehiclesLoadRequested()),
          child: const _DashboardBody(),
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: const CircleBorder(),
          onPressed: () {},
          child: const ImageIcon(AssetImage('assets/images/ai_Icon.png')),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

class _DashboardBody extends StatefulWidget {
  const _DashboardBody();

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  String? _selectedVehicleId;
  bool _dropdownOpen = false;
  OverlayEntry? _dropdownOverlay;
  final GlobalKey _vehicleCardKey = GlobalKey();

  void _closeDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
    if (mounted) setState(() => _dropdownOpen = false);
  }

  void _openDropdown(List<Vehicle> vehicles) {
    setState(() => _dropdownOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box =
          _vehicleCardKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) return;
      final offset = box.localToGlobal(Offset.zero);
      final size = box.size;
      final rect = Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
      final overlay = Overlay.of(context);
      _dropdownOverlay = OverlayEntry(
        builder: (ctx) => Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeDropdown,
              ),
            ),
            Positioned(
              left: rect.left,
              top: rect.bottom,
              width: rect.width,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
                child: _VehicleDropdownList(
                  vehicles: vehicles,
                  selectedId: _selectedVehicleId,
                  onSelect: (v) {
                    setState(() => _selectedVehicleId = v.id);
                    _closeDropdown();
                  },
                ),
              ),
            ),
          ],
        ),
      );
      overlay.insert(_dropdownOverlay!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<VehiclesBloc, VehiclesState>(
            buildWhen: (prev, curr) =>
                prev is VehiclesLoading != curr is VehiclesLoading ||
                (prev is VehiclesLoaded &&
                    curr is VehiclesLoaded &&
                    prev.vehicles != curr.vehicles),
            builder: (context, state) {
              final vehicles = state is VehiclesLoaded
                  ? state.vehicles
                  : <Vehicle>[];
              final displayed = vehicles.isEmpty
                  ? null
                  : vehicles
                            .where((v) => v.id == _selectedVehicleId)
                            .firstOrNull ??
                        (vehicles.isNotEmpty ? vehicles.first : null);
              return KeyedSubtree(
                key: _vehicleCardKey,
                child: _VehicleCard(
                  vehicle: displayed,
                  vehicles: vehicles,
                  dropdownOpen: _dropdownOpen,
                  onTap: () {
                    if (vehicles.isEmpty) {
                      Navigator.of(context).pushNamed('/vehicles');
                    } else if (_dropdownOpen) {
                      _closeDropdown();
                    } else {
                      _openDropdown(vehicles);
                    }
                  },
                ),
              );
            },
          ),
          const SizedBox(height: Spacing.lg),
          const _VehicleHealthSection(),
          const SizedBox(height: Spacing.lg),
          const _MaintenanceRemindersSection(),
          const SizedBox(height: Spacing.lg),
          const _QuickActionsSection(),
          const SizedBox(height: Spacing.lg),
          const _RecentActivitySection(),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    this.vehicle,
    required this.vehicles,
    required this.dropdownOpen,
    required this.onTap,
  });

  final Vehicle? vehicle;
  final List<Vehicle> vehicles;
  final bool dropdownOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayName = vehicle?.displayName ?? 'No vehicle';
    final plate = vehicle?.plateNumber ?? 'Add a vehicle';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: Dimensions.vehicleIconContainerSize,
              height: Dimensions.vehicleIconContainerSize,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
              ),
              child: const Icon(
                Icons.directions_car_rounded,
                color: Colors.white,
                size: Dimensions.vehicleIconSize,
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    plate,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              vehicles.isEmpty
                  ? Icons.add_rounded
                  : (dropdownOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded),
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleDropdownList extends StatelessWidget {
  const _VehicleDropdownList({
    required this.vehicles,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Vehicle> vehicles;
  final String? selectedId;
  final ValueChanged<Vehicle> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final v in vehicles)
              InkWell(
                onTap: () => onSelect(v),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.sm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(
                            BorderRadiusValues.lg,
                          ),
                        ),
                        child: const Icon(
                          Icons.directions_car_rounded,
                          color: AppColors.secondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              v.displayName,
                              style: AppTextStyles.bodyMedium.copyWith(
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
                        ),
                      ),
                      if (selectedId == v.id)
                        const Icon(
                          Icons.check,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VehicleHealthSection extends StatelessWidget {
  const _VehicleHealthSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Health',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _HealthIndicator(
                label: 'Engine',
                percentage: 85,
                color: AppColors.success,
              ),
              _HealthIndicator(
                label: 'Brakes',
                percentage: 50,
                color: AppColors.pending,
              ),
              _HealthIndicator(
                label: 'Tires',
                percentage: 25,
                color: AppColors.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthIndicator extends StatelessWidget {
  final String label;
  final int percentage;
  final Color color;

  const _HealthIndicator({
    required this.label,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: Dimensions.healthIndicatorSize,
          height: Dimensions.healthIndicatorSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: Dimensions.healthIndicatorSize,
                height: Dimensions.healthIndicatorSize,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 8,
                  backgroundColor: AppColors.surfaceMuted,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                '$percentage%',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _MaintenanceRemindersSection extends StatelessWidget {
  const _MaintenanceRemindersSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maintenance Reminders',
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: Spacing.md),
        const _ReminderCard(
          title: 'Oil Change',
          subtitle: 'Overdue by 5 days',
          statusLabel: 'Urgent',
          statusColor: AppColors.danger,
          borderColor: AppColors.danger,
          icon: Icons.oil_barrel_outlined,
        ),
        const SizedBox(height: Spacing.sm),
        const _ReminderCard(
          title: 'Tire Check',
          subtitle: 'Due in 3 days',
          statusLabel: 'Soon',
          statusColor: AppColors.pending,
          borderColor: AppColors.pending,
          icon: Icons.tire_repair_outlined,
        ),
        const SizedBox(height: Spacing.sm),
        const _ReminderCard(
          title: 'Brake Service',
          subtitle: 'Due in 2 weeks',
          statusLabel: 'Good',
          statusColor: AppColors.success,
          borderColor: AppColors.success,
          icon: Icons.build_outlined,
        ),
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusColor;
  final Color borderColor;
  final IconData icon;

  const _ReminderCard({
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusColor,
    required this.borderColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
        border: Border.all(color: borderColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: statusColor, size: 22),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
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
              color: statusColor,
              borderRadius: BorderRadius.circular(BorderRadiusValues.circular),
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
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: Spacing.md),
        Column(
          children: const [
            _PrimaryActionButton(
              label: 'Book Service',
              icon: Icons.calendar_today_outlined,
              gradientColors: [AppColors.secondary, AppColors.secondaryDark],
            ),
            SizedBox(height: Spacing.sm),
            _OutlinedActionButton(
              label: 'Find Nearby Garage',
              icon: Icons.location_on_outlined,
            ),
            SizedBox(height: Spacing.sm),
            _FilledActionButton(
              label: 'Chat with AI Assistant',
              icon: Icons.chat_bubble_outline,
            ),
          ],
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;

  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.textOnPrimary),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textOnPrimary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  final String label;
  final IconData icon;

  const _OutlinedActionButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.textPrimary),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilledActionButton extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FilledActionButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.secondary),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.secondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: Spacing.md),
        Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: const [
              _ActivityRow(
                icon: Icons.check_circle_rounded,
                iconColor: AppColors.success,
                title: 'Oil change completed',
                subtitle: '2 days ago',
              ),
              SizedBox(height: Spacing.sm),
              _ActivityRow(
                icon: Icons.event_note_rounded,
                iconColor: AppColors.pending,
                title: 'Service appointment booked',
                subtitle: '1 week ago',
              ),
              SizedBox(height: Spacing.sm),
              _ActivityRow(
                icon: Icons.add_circle_outline_rounded,
                iconColor: AppColors.secondary,
                title: 'Vehicle added',
                subtitle: '2 weeks ago',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _ActivityRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: Spacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

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
              _BottomNavItem(
                icon: Icons.home_filled,
                label: 'Home',
                isActive: true,
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  '/driver-dashboard',
                  (route) => route.isFirst,
                ),
              ),
              _BottomNavItem(
                icon: Icons.directions_car_filled,
                label: 'Vehicles',
                onTap: () => Navigator.of(context).pushNamed('/vehicles'),
              ),
              _BottomNavItem(
                icon: Icons.handyman_outlined,
                label: 'Service',
                onTap: () {
                  Navigator.of(context).pushNamed('/services');
                },
              ),
              const _BottomNavItem(
                icon: Icons.people_alt_outlined,
                label: 'Community',
              ),
              const _BottomNavItem(
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

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _BottomNavItem({
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
