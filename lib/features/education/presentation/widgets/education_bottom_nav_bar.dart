library;

import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum EducationShellTab {
  home,
  vehicles,
  service,
  community,
  education,
}

/// Matches dashboard / community bottom bar; highlights [current].
class EducationBottomNavBar extends StatelessWidget {
  const EducationBottomNavBar({super.key, required this.current});

  final EducationShellTab current;

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
              _Item(
                icon: Icons.home_filled,
                label: 'Home',
                active: current == EducationShellTab.home,
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                      '/driver-dashboard',
                      (route) => route.isFirst,
                    ),
              ),
              _Item(
                icon: Icons.directions_car_filled,
                label: 'Vehicle',
                active: current == EducationShellTab.vehicles,
                onTap: () => Navigator.of(context).pushNamed('/vehicles'),
              ),
              _Item(
                icon: Icons.handyman_outlined,
                label: 'Service',
                active: current == EducationShellTab.service,
                onTap: () => Navigator.of(context).pushNamed('/services'),
              ),
              _Item(
                icon: Icons.people_alt_outlined,
                label: 'Community',
                active: current == EducationShellTab.community,
                onTap: () => Navigator.of(context).pushNamed('/community'),
              ),
              _Item(
                icon: Icons.menu_book_outlined,
                label: 'Education',
                active: current == EducationShellTab.education,
                onTap: () {
                  if (current != EducationShellTab.education) {
                    Navigator.of(context).pushReplacementNamed('/education');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    required this.active,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.textPrimary : AppColors.textSecondary;
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
