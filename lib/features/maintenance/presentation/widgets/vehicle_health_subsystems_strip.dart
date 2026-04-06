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
    this.collapseCustomToOther = false,
  });

  final List<VehicleHealthComponent> components;
  final String? sectionTitle;
  final bool collapseCustomToOther;

  static const Set<String> _knownSubsystemLabels = {
    'engine',
    'brakes',
    'tires',
    'battery',
    'coolant',
    'transmission',
    'air filter',
    'wipers & lights',
    'other',
  };

  List<VehicleHealthComponent> _collapseToOther(List<VehicleHealthComponent> list) {
    final out = <VehicleHealthComponent>[];
    final custom = <VehicleHealthComponent>[];
    for (final c in list) {
      final k = c.label.trim().toLowerCase();
      if (_knownSubsystemLabels.contains(k)) {
        out.add(c);
      } else {
        custom.add(c);
      }
    }
    if (custom.isNotEmpty) {
      final sum = custom.fold<int>(0, (a, c) => a + c.percent);
      final avg = (sum / custom.length).round();
      out.add(VehicleHealthComponent(label: 'Other', percent: avg));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    if (components.isEmpty) return const SizedBox.shrink();
    final base = collapseCustomToOther ? _collapseToOther(components) : components;
    final ordered = orderedHealthComponents(base);
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

            // Padding keeps rings from touching/clipping on card edges.
            final scroll = SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              // Clip to the card bounds so rings don't paint outside.
              // Safe because the ring stroke is inset inside its box.
              clipBehavior: Clip.hardEdge,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: Spacing.xs,
                ),
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
