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
import '../../../maintenance/application/usecases/get_vehicle_health_usecase.dart';
import '../../../maintenance/domain/entities/maintenance_upcoming.dart';
import '../../../maintenance/domain/entities/maintenance_history.dart';
import '../../../maintenance/domain/entities/vehicle_health.dart';
import '../../../maintenance/presentation/bloc/maintenance_bloc.dart';
import '../../../maintenance/presentation/bloc/maintenance_event.dart';
import '../../../maintenance/presentation/bloc/maintenance_state.dart';
import '../../../maintenance/presentation/utils/vehicle_health_ui.dart';
import '../../../maintenance/presentation/widgets/vehicle_health_subsystems_strip.dart';
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
      appBar: const NavAppBar(title: 'CarCare', notificationCount: null),
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
          onPressed: () => Navigator.of(context).pushNamed('/ai-chat'),
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
          BlocBuilder<VehiclesBloc, VehiclesState>(
            builder: (context, state) {
              final vehicles = state is VehiclesLoaded ? state.vehicles : const <Vehicle>[];
              final selected = vehicles.isEmpty
                  ? null
                  : vehicles.where((v) => v.id == _selectedVehicleId).firstOrNull ?? vehicles.firstOrNull;
              return _VehicleHealthSection(selectedVehicleId: selected?.id);
            },
          ),
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

class _VehicleHealthSection extends StatefulWidget {
  const _VehicleHealthSection({required this.selectedVehicleId});

  final String? selectedVehicleId;

  @override
  State<_VehicleHealthSection> createState() => _VehicleHealthSectionState();
}

class _VehicleHealthSectionState extends State<_VehicleHealthSection> {
  VehicleHealth? _health;
  bool _loading = false;
  Object? _error;

  Future<void> _load() async {
    final id = widget.selectedVehicleId?.trim();
    if (id == null || id.isEmpty) {
      setState(() {
        _health = null;
        _error = null;
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final health = await getIt<GetVehicleHealthUseCase>()(id);
      if (!mounted) return;
      if (widget.selectedVehicleId?.trim() != id) return;
      setState(() {
        _health = health;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _health = null;
        _loading = false;
        _error = e;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _VehicleHealthSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedVehicleId != widget.selectedVehicleId) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.selectedVehicleId?.trim();

    BoxDecoration cardDeco() => BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        );

    if (id == null || id.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: cardDeco(),
        child: Text(
          'Add or select a vehicle to load car health from the server.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    if (_loading && _health == null) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: cardDeco(),
        child: const CircularProgressIndicator(),
      );
    }

    if (_error != null && _health == null) {
      return Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: cardDeco(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Could not load vehicle health.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              _error.toString(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final h = _health ?? const VehicleHealth(overallPercent: 0);
    final ordered = orderedHealthComponents(h.components);
    final overallColor = vehicleHealthColorForPercent(h.overallPercent);

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: cardDeco(),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: (h.overallPercent.clamp(0, 100)) / 100,
                        strokeWidth: 8,
                        backgroundColor: AppColors.surfaceMuted,
                        valueColor: AlwaysStoppedAnimation<Color>(overallColor),
                      ),
                    ),
                    Text(
                      '${h.overallPercent.clamp(0, 100)}%',
                      style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall car health',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (h.summary != null && h.summary!.trim().isNotEmpty)
                          ? h.summary!.trim()
                          : 'Scores come from your maintenance activity and garage data for this vehicle.',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (ordered.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            VehicleHealthSubsystemsStrip(
              components: ordered,
              collapseCustomToOther: true,
            ),
          ] else ...[
            const SizedBox(height: Spacing.sm),
            Text(
              'No subsystem data yet.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Maintenance Reminders',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/vehicles',
                (route) => route.isFirst,
                arguments: {'tab': 1},
              ),
              child: Text(
                'View all',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        BlocProvider(
          create: (_) => getIt<MaintenanceBloc>()..add(const MaintenanceLoadRequested()),
          child: BlocBuilder<MaintenanceBloc, MaintenanceState>(
            builder: (context, state) {
              final items = state.upcoming.where((u) => u.isActiveReminder).take(3).toList();
              if (state.loading && items.isEmpty) {
                return const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()));
              }
              if (items.isEmpty) {
                return Text(
                  'No reminders yet. Schedule maintenance to get started.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                );
              }
              return Column(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    _ReminderCard(
                      title: items[i].title,
                      vehicleMakeModel: _trimOrNull(items[i].vehicleLabel),
                      vehiclePlate: _trimOrNull(items[i].vehiclePlate),
                      subtitle: _dueText(items[i].scheduledAt),
                      statusLabel: _statusLabelFromItem(items[i]),
                      statusColor: _statusColorFromItem(items[i]),
                      borderColor: _statusColorFromItem(items[i]),
                      icon: _iconFor(items[i].title),
                    ),
                    if (i != items.length - 1) const SizedBox(height: Spacing.sm),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  static String? _trimOrNull(String? s) {
    final t = s?.trim();
    if (t == null || t.isEmpty) return null;
    return t;
  }

  static String _dueText(DateTime date) {
    final today = DateTime.now();
    final d0 = DateTime(today.year, today.month, today.day);
    final d1 = DateTime(date.year, date.month, date.day);
    final diff = d1.difference(d0).inDays;
    if (diff < 0) return 'Overdue by ${diff.abs()} days';
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    if (diff < 7) return 'Due in $diff days';
    final weeks = (diff / 7).round();
    return 'Due in $weeks weeks';
  }

  static String _statusLabelFromItem(MaintenanceUpcoming m) {
    final s = m.displayStatus?.toUpperCase();
    if (s != null && s.isNotEmpty) {
      switch (s) {
        case 'URGENT':
          return 'Urgent';
        case 'SOON':
          return 'Soon';
        case 'GOOD':
          return 'Good';
        case 'DONE':
          return 'Done';
        default:
          return s;
      }
    }
    return _statusLabel(m.scheduledAt);
  }

  static String _statusLabel(DateTime date) {
    final today = DateTime.now();
    final d0 = DateTime(today.year, today.month, today.day);
    final d1 = DateTime(date.year, date.month, date.day);
    final diff = d1.difference(d0).inDays;
    if (diff < 0) return 'Urgent';
    if (diff <= 3) return 'Soon';
    return 'Good';
  }

  static Color _statusColorFromItem(MaintenanceUpcoming m) {
    final s = m.displayStatus?.toUpperCase();
    if (s != null) {
      switch (s) {
        case 'URGENT':
          return AppColors.danger;
        case 'SOON':
          return AppColors.pending;
        case 'GOOD':
          return AppColors.success;
        case 'DONE':
          return AppColors.textSecondary;
      }
    }
    return _statusColor(m.scheduledAt);
  }

  static Color _statusColor(DateTime date) {
    final today = DateTime.now();
    final d0 = DateTime(today.year, today.month, today.day);
    final d1 = DateTime(date.year, date.month, date.day);
    final diff = d1.difference(d0).inDays;
    if (diff < 0) return AppColors.danger;
    if (diff <= 3) return AppColors.pending;
    return AppColors.success;
  }

  static IconData _iconFor(String title) {
    final t = title.toLowerCase();
    if (t.contains('oil')) return Icons.oil_barrel_outlined;
    if (t.contains('tire')) return Icons.tire_repair_outlined;
    if (t.contains('brake')) return Icons.build_outlined;
    return Icons.build_outlined;
  }
}

class _ReminderCard extends StatelessWidget {
  final String title;
  final String? vehicleMakeModel;
  final String? vehiclePlate;
  final String subtitle;
  final String statusLabel;
  final Color statusColor;
  final Color borderColor;
  final IconData icon;

  const _ReminderCard({
    required this.title,
    this.vehicleMakeModel,
    this.vehiclePlate,
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
                if (vehicleMakeModel != null && vehicleMakeModel!.isNotEmpty) ...[
                  const SizedBox(height: Spacing.xs),
                  Text(
                    vehicleMakeModel!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (vehiclePlate != null && vehiclePlate!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Plate $vehiclePlate',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
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
          children: [
            _PrimaryActionButton(
              label: 'Book Service',
              icon: Icons.calendar_today_outlined,
              gradientColors: [AppColors.secondary, AppColors.secondaryDark],
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/services',
                (route) => route.isFirst,
              ),
            ),
            SizedBox(height: Spacing.sm),
            _OutlinedActionButton(
              label: 'Find Nearby Garage',
              icon: Icons.location_on_outlined,
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/services',
                (route) => route.isFirst,
              ),
            ),
            SizedBox(height: Spacing.sm),
            _FilledActionButton(
              label: 'Chat with AI Assistant',
              icon: Icons.chat_bubble_outline,
              onTap: () => Navigator.of(context).pushNamed('/ai-chat'),
            ),
            const SizedBox(height: Spacing.sm),
            _OutlinedActionButton(
              label: 'Maintenance History',
              icon: Icons.history_rounded,
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/vehicles',
                (route) => route.isFirst,
                arguments: {'tab': 2},
              ),
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
  final VoidCallback? onTap;

  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.gradientColors,
    this.onTap,
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
          onTap: onTap,
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
  final VoidCallback? onTap;

  const _OutlinedActionButton({required this.label, required this.icon, this.onTap});

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
          onTap: onTap,
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
  final VoidCallback? onTap;

  const _FilledActionButton({required this.label, required this.icon, this.onTap});

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
          onTap: onTap,
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

class _RecentActivitySection extends StatefulWidget {
  const _RecentActivitySection();

  @override
  State<_RecentActivitySection> createState() => _RecentActivitySectionState();
}

class _RecentActivitySectionState extends State<_RecentActivitySection> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<VehiclesBloc>()..add(const VehiclesLoadRequested()),
        ),
        BlocProvider(
          create: (_) => getIt<MaintenanceBloc>()..add(const MaintenanceLoadRequested()),
        ),
      ],
      child: Builder(
        builder: (context) {
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
                child: BlocBuilder<MaintenanceBloc, MaintenanceState>(
                  builder: (context, mState) {
                    return BlocBuilder<VehiclesBloc, VehiclesState>(
                      builder: (context, vState) {
                        final items = _buildRecentActivities(
                          maintenance: mState,
                          vehicles: vState,
                        );
                        if (items.isEmpty && (mState.loading || vState is VehiclesLoading || vState is VehiclesInitial)) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(Spacing.md),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (items.isEmpty) {
                          return Text(
                            'No recent activity yet.',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          );
                        }
                        return Column(
                          children: [
                            for (int i = 0; i < items.length; i++) ...[
                              _ActivityRow(
                                icon: items[i].icon,
                                iconColor: items[i].iconColor,
                                title: items[i].title,
                                subtitle: items[i].subtitle,
                              ),
                              if (i != items.length - 1) const SizedBox(height: Spacing.sm),
                            ],
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_ActivityItem> _buildRecentActivities({
    required MaintenanceState maintenance,
    required VehiclesState vehicles,
  }) {
    final now = DateTime.now();
    final items = <_ActivityItem>[];

    final history = maintenance.history.toList()..sort((a, b) => b.date.compareTo(a.date));
    for (final h in history.take(3)) {
      items.add(
        _ActivityItem(
          ts: h.date,
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.success,
          title: '${h.title} completed',
          subtitle: _historyActivitySubtitle(h, vehicles, now),
        ),
      );
    }

    if (vehicles is VehiclesLoaded) {
      final vs = vehicles.vehicles
          .where((v) => (v.createdAt ?? v.updatedAt) != null)
          .toList()
        ..sort((a, b) => ((b.createdAt ?? b.updatedAt)!).compareTo((a.createdAt ?? a.updatedAt)!));
      for (final v in vs.take(2)) {
        final ts = (v.createdAt ?? v.updatedAt)!;
        items.add(
          _ActivityItem(
            ts: ts,
            icon: Icons.add_circle_outline_rounded,
            iconColor: AppColors.secondary,
            title: 'Vehicle added: ${_vehicleLabel(v)}',
            subtitle: _timeAgo(ts, now),
          ),
        );
      }
    }

    items.sort((a, b) => b.ts.compareTo(a.ts));
    return items.take(5).toList();
  }

  static String _historyActivitySubtitle(MaintenanceHistory h, VehiclesState vehicles, DateTime now) {
    final ago = _timeAgo(h.date, now);
    if (vehicles is! VehiclesLoaded || h.vehicleId == null || h.vehicleId!.isEmpty) {
      return ago;
    }
    for (final v in vehicles.vehicles) {
      if (v.id == h.vehicleId) {
        final name = v.displayName.trim();
        if (name.isNotEmpty) return '$name · $ago';
        return '${v.plateNumber} · $ago';
      }
    }
    return ago;
  }

  static String _vehicleLabel(Vehicle v) {
    final name = v.displayName.trim();
    if (name.isNotEmpty) return name;
    return v.plateNumber;
  }

  static String _timeAgo(DateTime ts, DateTime now) {
    final diff = now.difference(ts);
    if (diff.inMinutes < 2) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    final weeks = (diff.inDays / 7).floor();
    if (weeks < 5) return '$weeks weeks ago';
    final months = (diff.inDays / 30).floor();
    return '$months months ago';
  }
}

class _ActivityItem {
  const _ActivityItem({
    required this.ts,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final DateTime ts;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
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
              _BottomNavItem(
                icon: Icons.people_alt_outlined,
                label: 'Community',
                onTap: () => Navigator.of(context).pushNamed('/community'),
              ),
              _BottomNavItem(
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
