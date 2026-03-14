library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/border_radius.dart';
import '../constants/spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/auth/domain/entities/driver_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

/// App navigation drawer with user header, navigation, account, and logout.
/// Pass [currentRoute] to highlight the active item (e.g. '/driver-dashboard', '/services').
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, this.currentRoute});

  final String? currentRoute;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (prev, next) =>
          prev is AuthAuthenticated != next is AuthAuthenticated ||
          (prev is AuthAuthenticated && next is AuthAuthenticated &&
              prev.user != next.user),
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        return Drawer(
          backgroundColor: Colors.white,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DrawerHeader(user: user, onClose: () => Navigator.of(context).pop()),
                const SizedBox(height: Spacing.sm),
                _SectionLabel(label: 'NAVIGATION'),
                _DrawerTile(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  isActive: currentRoute == '/driver-dashboard',
                  onTap: () => _navigate(context, '/driver-dashboard'),
                ),
                _DrawerTile(
                  icon: Icons.directions_car_outlined,
                  activeIcon: Icons.directions_car,
                  label: 'My Vehicles',
                  isActive: currentRoute == '/vehicles',
                  onTap: () => _navigate(context, '/vehicles'),
                ),
                _DrawerTile(
                  icon: Icons.build_outlined,
                  activeIcon: Icons.build,
                  label: 'Service',
                  isActive: currentRoute == '/services',
                  onTap: () => _navigate(context, '/services'),
                ),
                _DrawerTile(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'Community',
                  isActive: currentRoute == '/community',
                  onTap: () => _navigate(context, '/driver-dashboard'),
                ),
                _DrawerTile(
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book,
                  label: 'Education',
                  isActive: currentRoute == '/education',
                  onTap: () => _navigate(context, '/driver-dashboard'),
                ),
                const SizedBox(height: Spacing.md),
                _SectionLabel(label: 'ACCOUNT'),
                _DrawerTile(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  isActive: currentRoute == '/profile',
                  onTap: () => _navigate(context, '/profile'),
                ),
                _DrawerTile(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Settings',
                  isActive: currentRoute == '/settings',
                  onTap: () => _navigate(context, '/driver-dashboard'),
                ),
                _DrawerTile(
                  icon: Icons.help_outline,
                  activeIcon: Icons.help,
                  label: 'Help & Support',
                  isActive: false,
                  onTap: () => _navigate(context, '/driver-dashboard'),
                ),
                const Spacer(),
                const Divider(height: 1),
                _LogoutTile(
                  onTap: () => _logout(context),
                ),
                const SizedBox(height: Spacing.md),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.of(context).pop();
    if (currentRoute != route) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pop();
    context.read<AuthBloc>().add(const LogoutRequested());
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({this.user, required this.onClose});

  final DriverUser? user;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final name = user != null
        ? '${user!.firstName} ${user!.lastName}'.trim()
        : 'Guest';
    final email = user?.email ?? '—';

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.sm, Spacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.person,
              size: 32,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  email,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.xs),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
      child: Material(
        color: isActive ? AppColors.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
        child: ListTile(
          leading: Icon(
            isActive ? activeIcon : icon,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            size: 24,
          ),
          title: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          trailing: isActive
              ? Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary)
              : null,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.logout, color: AppColors.danger, size: 24),
      title: Text(
        'Logout',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.danger,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}
