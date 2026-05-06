library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/nav_app_bar.dart';
import '../../../../injection/service_locator.dart';
import '../../../vehicles/presentation/bloc/vehicles_bloc.dart';
import '../../../vehicles/presentation/bloc/vehicles_event.dart';
import '../bloc/maintenance_bloc.dart';
import '../bloc/maintenance_event.dart';
import '../bloc/maintenance_state.dart';
import '../widgets/maintenance_upcoming_list_item.dart';
import 'schedule_maintenance_page.dart';

class MaintenanceUpcomingPage extends StatefulWidget {
  const MaintenanceUpcomingPage({super.key});

  @override
  State<MaintenanceUpcomingPage> createState() => _MaintenanceUpcomingPageState();
}

class _MaintenanceUpcomingPageState extends State<MaintenanceUpcomingPage> {
  @override
  void initState() {
    super.initState();
    context.read<MaintenanceBloc>().add(const MaintenanceLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    if (_maybeVehiclesBloc(context) == null) {
      return BlocProvider(
        create: (_) => getIt<VehiclesBloc>()..add(const VehiclesLoadRequested()),
        child: Builder(builder: (context) => _buildScaffold(context)),
      );
    }
    return _buildScaffold(context);
  }

  Widget _buildScaffold(BuildContext context) {
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
                          'Upcoming Maintenance',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Scheduled and recommended services',
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
                  builder: (context, state) {
                    final items = state.upcoming.where((u) => u.isActiveReminder).toList();
                    if (state.loading && items.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          'No upcoming maintenance.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
                      itemBuilder: (context, i) {
                        final m = items[i];
                        return MaintenanceUpcomingListItem(
                          item: m,
                          onDelete: () {
                            context.read<MaintenanceBloc>().add(MaintenanceUpcomingDeleteRequested(m.id));
                          },
                          onToggleReminder: () {
                            context.read<MaintenanceBloc>().add(MaintenanceToggleReminderRequested(m.id));
                          },
                          onMarkDone: m.canMarkDoneFromUi
                              ? () => context.read<MaintenanceBloc>().add(MaintenanceMarkDoneRequested(m.id))
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: Spacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final vehiclesBloc = _maybeVehiclesBloc(context);
                    final maintenanceBloc = context.read<MaintenanceBloc>();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            if (vehiclesBloc != null) BlocProvider.value(value: vehiclesBloc),
                            BlocProvider.value(value: maintenanceBloc),
                          ],
                          child: const ScheduleMaintenancePage(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: const Text('Set Maintenance Reminder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Vehicle picking now happens on the dedicated schedule screen.
}

VehiclesBloc? _maybeVehiclesBloc(BuildContext context) {
  try {
    return BlocProvider.of<VehiclesBloc>(context);
  } catch (_) {
    return null;
  }
}

