library;

import 'package:flutter/material.dart';

import '../constants/dimensions.dart';
import '../constants/spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Common app bar for all main nav screens (dashboard, vehicles, services).
/// Uses drawer menu, optional title, and optional notification + profile actions.
class NavAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NavAppBar({
    super.key,
    this.title,
    this.centerTitle = true,
    this.showActions = true,
    this.notificationCount,
  });

  /// Screen title; null for no title.
  final String? title;

  /// Whether to center the title.
  final bool centerTitle;

  /// Whether to show notification icon and profile avatar on the right.
  final bool showActions;

  /// Badge count on notification icon; null hides badge.
  final int? notificationCount;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: title != null
          ? Text(
              title!,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      centerTitle: centerTitle,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      actions: showActions
          ? [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {},
                  ),
                  if (notificationCount != null && notificationCount! > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            notificationCount! > 99
                                ? '99+'
                                : notificationCount.toString(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: Spacing.xs),
              CircleAvatar(
                radius: Dimensions.profileAvatarRadius,
                backgroundColor: AppColors.surfaceMuted,
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: Spacing.md),
            ]
          : null,
    );
  }
}
