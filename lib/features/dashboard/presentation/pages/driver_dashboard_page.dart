import 'package:flutter/material.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/widgets/app_drawer.dart';

class DriverDashboardPage extends StatelessWidget {
  const DriverDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: '/driver-dashboard'),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _VehicleCard(),
              SizedBox(height: Spacing.lg),
              _VehicleHealthSection(),
              SizedBox(height: Spacing.lg),
              _MaintenanceRemindersSection(),
              SizedBox(height: Spacing.lg),
              _QuickActionsSection(),
              SizedBox(height: Spacing.lg),
              _RecentActivitySection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
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
        const SizedBox(width: Spacing.xs),
        const CircleAvatar(
          radius: Dimensions.profileAvatarRadius,
          backgroundImage: AssetImage('assets/avatar_placeholder.png'),
        ),
        const SizedBox(width: Spacing.md),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 10),
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
              Icons.directions_car_filled,
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
                  'Honda Civic 2020',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text('ABC-123', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
        ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Health',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
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
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: statusColor),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(subtitle, style: AppTextStyles.bodySmall),
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
                color: Colors.white,
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
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
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
                Icon(icon, color: Colors.white),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
        border: Border.all(color: AppColors.border),
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
                Icon(icon, color: Colors.black),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.black,
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
                Icon(icon, color: Colors.black),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.black,
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
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: Spacing.md),
        Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
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
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(subtitle, style: AppTextStyles.bodySmall),
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
              const _BottomNavItem(
                icon: Icons.home_filled,
                label: 'Home',
                isActive: true,
              ),
              const _BottomNavItem(
                icon: Icons.directions_car_filled,
                label: 'Vehicles',
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
