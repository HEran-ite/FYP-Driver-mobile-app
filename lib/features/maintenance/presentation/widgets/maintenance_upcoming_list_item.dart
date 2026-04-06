library;

import 'package:flutter/material.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/maintenance_upcoming.dart';

class MaintenanceUpcomingListItem extends StatelessWidget {
  const MaintenanceUpcomingListItem({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onToggleReminder,
    this.onMarkDone,
  });

  final MaintenanceUpcoming item;
  final VoidCallback onDelete;
  final VoidCallback onToggleReminder;
  final VoidCallback? onMarkDone;

  static String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = months[d.month - 1];
    return '$m ${d.day}, ${d.year}';
  }

  static String _statusLabel(MaintenanceUpcoming m) {
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
    final today = DateTime.now();
    final d0 = DateTime(today.year, today.month, today.day);
    final d1 = DateTime(m.scheduledAt.year, m.scheduledAt.month, m.scheduledAt.day);
    final diff = d1.difference(d0).inDays;
    if (diff < 0) return 'Urgent';
    if (diff <= 3) return 'Soon';
    return 'Good';
  }

  static Color _statusColor(MaintenanceUpcoming m) {
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
    final today = DateTime.now();
    final d0 = DateTime(today.year, today.month, today.day);
    final d1 = DateTime(m.scheduledAt.year, m.scheduledAt.month, m.scheduledAt.day);
    final diff = d1.difference(d0).inDays;
    if (diff < 0) return AppColors.danger;
    if (diff <= 3) return AppColors.pending;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item);
    final makeModel = item.vehicleLabel?.trim();
    final plate = item.vehiclePlate?.trim();
    final hasMakeModel = makeModel != null && makeModel.isNotEmpty;
    final hasPlate = plate != null && plate.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (hasMakeModel) ...[
                      const SizedBox(height: 4),
                      Text(
                        makeModel,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (hasPlate) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Plate $plate',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: Spacing.sm),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          _formatDate(item.scheduledAt),
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(BorderRadiusValues.circular),
                ),
                child: Text(
                  _statusLabel(item),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onToggleReminder,
                  icon: Icon(
                    item.reminderEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_outlined,
                    size: 18,
                  ),
                  label: Text(item.reminderEnabled ? 'Reminder on' : 'Reminder off'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              if (onMarkDone != null) ...[
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onMarkDone,
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('Done'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Spacing.sm),
          OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('Delete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: BorderSide(color: AppColors.danger.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
