library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/nav_app_bar.dart';
import '../../../vehicles/domain/entities/vehicle.dart';
import '../../../vehicles/presentation/bloc/vehicles_bloc.dart';
import '../../../vehicles/presentation/bloc/vehicles_event.dart';
import '../../../vehicles/presentation/bloc/vehicles_state.dart';
import '../bloc/maintenance_bloc.dart';
import '../bloc/maintenance_event.dart';
import '../bloc/maintenance_state.dart';
import '../models/maintenance_timeline_entry.dart';
import '../widgets/maintenance_timeline_list_item.dart';

class MaintenanceHistoryPage extends StatefulWidget {
  const MaintenanceHistoryPage({super.key});

  @override
  State<MaintenanceHistoryPage> createState() => _MaintenanceHistoryPageState();
}

class _MaintenanceHistoryPageState extends State<MaintenanceHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<MaintenanceBloc>().add(const MaintenanceLoadRequested());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        context.read<VehiclesBloc>().add(const VehiclesLoadRequested());
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const NavAppBar(title: 'CarCare', notificationCount: 3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Maintenance History',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Scheduled reminders and completed services',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              Expanded(
                child: BlocBuilder<MaintenanceBloc, MaintenanceState>(
                  builder: (context, mState) {
                    final timeline = buildMaintenanceTimeline(mState);
                    if (mState.loading && timeline.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return BlocBuilder<VehiclesBloc, VehiclesState>(
                      builder: (context, vState) {
                        final vehicles = vState is VehiclesLoaded ? vState.vehicles : const <Vehicle>[];
                        if (timeline.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                              child: Text(
                                'Nothing here yet.\n\n'
                                'Reminders and completed services appear here with status '
                                '(Good, Soon, Overdue, Done). Use Upcoming to schedule or mark work complete.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: timeline.length,
                          separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
                          itemBuilder: (context, i) {
                            final entry = timeline[i];
                            return MaintenanceTimelineListItem(
                              entry: entry,
                              vehicles: vehicles,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
