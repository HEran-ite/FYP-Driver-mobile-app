library;

import 'package:flutter/material.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../vehicles/domain/entities/vehicle.dart';
import '../../domain/entities/maintenance_history.dart';
import '../../domain/entities/maintenance_upcoming.dart';
import '../models/maintenance_timeline_entry.dart'
    show MaintenanceTimelineEntry, kDeletedReminderHistoryTitlePrefix;

/// History timeline row: no actions, only a clear status (Soon / Good / Overdue / Done).
class MaintenanceTimelineReadOnlyCard extends StatelessWidget {
  const MaintenanceTimelineReadOnlyCard({
    super.key,
    required this.entry,
    required this.vehicles,
  });

  final MaintenanceTimelineEntry entry;
  final List<Vehicle> vehicles;

  static String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = months[d.month - 1];
    return '$m ${d.day}, ${d.year}';
  }

  static String? _formatCost(num? n) {
    if (n == null) return null;
    if (n == n.roundToDouble()) return n.toInt().toString();
    return n.toStringAsFixed(2);
  }

  Vehicle? _vehicleFor(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final v in vehicles) {
      if (v.id == id) return v;
    }
    return null;
  }

  /// Status text + color for a scheduled reminder.
  static (String, Color) _reminderStatus(MaintenanceUpcoming m) {
    if (m.completedAt != null) {
      return ('Done', AppColors.success);
    }
    final s = m.displayStatus?.toUpperCase();
    if (s != null && s.isNotEmpty) {
      switch (s) {
        case 'URGENT':
          return ('Overdue', AppColors.danger);
        case 'SOON':
          return ('Soon', AppColors.pending);
        case 'GOOD':
          return ('Good', AppColors.success);
        case 'DONE':
          return ('Done', AppColors.textSecondary);
        case 'CANCELLED':
        case 'DELETED':
          return ('Deleted', AppColors.textSecondary);
        default:
          return (s[0] + s.substring(1).toLowerCase(), AppColors.textSecondary);
      }
    }
    final today = DateTime.now();
    final d0 = DateTime(today.year, today.month, today.day);
    final d1 = DateTime(m.scheduledAt.year, m.scheduledAt.month, m.scheduledAt.day);
    final diff = d1.difference(d0).inDays;
    if (diff < 0) return ('Overdue', AppColors.danger);
    if (diff <= 3) return ('Soon', AppColors.pending);
    return ('Good', AppColors.success);
  }

  /// Status for a logged / completed service row.
  static (String, Color) _recordStatus(MaintenanceHistory h) {
    if (h.title.startsWith(kDeletedReminderHistoryTitlePrefix)) {
      return ('Deleted', AppColors.textSecondary);
    }
    return ('Done', AppColors.success);
  }

  @override
  Widget build(BuildContext context) {
    if (entry.isReminder) {
      return _buildReminderCard(entry.reminder!);
    }
    return _buildRecordCard(entry.history!);
  }

  Widget _buildReminderCard(MaintenanceUpcoming m) {
    final (statusLabel, statusColor) = _reminderStatus(m);
    final makeModel = m.vehicleLabel?.trim();
    final plate = m.vehiclePlate?.trim();
    final v = _vehicleFor(m.vehicleId);

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_available_outlined, color: statusColor, size: 22),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (makeModel != null && makeModel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    makeModel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (plate != null && plate.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Plate $plate',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ] else if (v != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${v.displayName} · Plate ${v.plateNumber}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: Text(
                        m.completedAt != null
                            ? 'Completed ${_formatDate(m.completedAt!)} · Due ${_formatDate(m.scheduledAt)}'
                            : 'Due ${_formatDate(m.scheduledAt)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          _StatusPill(label: statusLabel, color: statusColor),
        ],
      ),
    );
  }

  Widget _buildRecordCard(MaintenanceHistory h) {
    final (statusLabel, statusColor) = _recordStatus(h);
    final displayTitle = h.title.startsWith(kDeletedReminderHistoryTitlePrefix)
        ? h.title.substring(kDeletedReminderHistoryTitlePrefix.length).trim()
        : h.title;
    final v = _vehicleFor(h.vehicleId);
    final costStr = _formatCost(h.amount);

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_outline_rounded, color: statusColor, size: 22),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (v != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${v.displayName} · Plate ${v.plateNumber}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (h.garageName != null && h.garageName!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      h.garageName!.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: Spacing.xs),
                      Expanded(
                        child: Text(
                          _formatDate(h.date),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                if (costStr != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Cost $costStr',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          _StatusPill(label: statusLabel, color: statusColor),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs + 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(BorderRadiusValues.circular),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
