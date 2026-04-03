library;

import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/vehicle_health.dart';
import '../utils/vehicle_health_ui.dart';

/// Horizontal scroll of per-subsystem health rings (Engine, Brakes, etc.).
class VehicleHealthSubsystemsStrip extends StatelessWidget {
  const VehicleHealthSubsystemsStrip({
    super.key,
    required this.components,
    this.sectionTitle = 'Subsystem health',
  });

  final List<VehicleHealthComponent> components;
  final String? sectionTitle;

  @override
  Widget build(BuildContext context) {
    if (components.isEmpty) return const SizedBox.shrink();
    final ordered = orderedHealthComponents(components);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionTitle != null && sectionTitle!.trim().isNotEmpty) ...[
          Text(
            sectionTitle!.trim(),
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.sm),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = Spacing.md;
            final ringSize = Dimensions.healthIndicatorSize;
            final maxW = constraints.maxWidth;
            final bounded = constraints.hasBoundedWidth &&
                maxW.isFinite &&
                maxW > 0;

            final row = Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < ordered.length; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  _SubsystemRing(
                    label: ordered[i].label,
                    percentage: ordered[i].percent.clamp(0, 100),
                    color: vehicleHealthColorForPercent(ordered[i].percent),
                    size: ringSize,
                  ),
                ],
              ],
            );

            // Vertical padding so ring strokes are not clipped by the scroll viewport.
            final scroll = SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: row,
              ),
            );

            if (bounded) {
              return SizedBox(width: maxW, child: scroll);
            }
            return scroll;
          },
        ),
      ],
    );
  }
}

class _SubsystemRing extends StatelessWidget {
  const _SubsystemRing({
    required this.label,
    required this.percentage,
    required this.color,
    required this.size,
  });

  final String label;
  final int percentage;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final stroke = size >= 64 ? 8.0 : 6.0;
    final pctStyle = size >= 64
        ? AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)
        : AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600);
    // Inset the indicator so its stroke stays inside layout bounds (Stack clips by default).
    final inset = stroke / 2;
    final inner = (size - stroke).clamp(1.0, size);
    return SizedBox(
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(inset),
                  child: SizedBox(
                    width: inner,
                    height: inner,
                    child: CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: stroke,
                      backgroundColor: AppColors.surfaceMuted,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                Text('$percentage%', style: pctStyle, textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: size >= 64
                ? AppTextStyles.bodySmall
                : AppTextStyles.bodySmall.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
