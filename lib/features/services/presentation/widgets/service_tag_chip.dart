library;

import 'package:flutter/material.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'service_text_formatter.dart';

class ServiceTagChip extends StatelessWidget {
  const ServiceTagChip({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(BorderRadiusValues.sm),
      ),
      child: Text(
        formatServiceLabel(label),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

