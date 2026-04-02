library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../vehicles/domain/entities/vehicle.dart';
import '../../../vehicles/presentation/bloc/vehicles_bloc.dart';
import '../../../vehicles/presentation/bloc/vehicles_event.dart';
import '../../../vehicles/presentation/bloc/vehicles_state.dart';
import '../bloc/maintenance_bloc.dart';
import '../bloc/maintenance_event.dart';
import '../bloc/maintenance_state.dart';

class ScheduleMaintenancePage extends StatefulWidget {
  const ScheduleMaintenancePage({super.key});

  @override
  State<ScheduleMaintenancePage> createState() => _ScheduleMaintenancePageState();
}

class _ScheduleMaintenancePageState extends State<ScheduleMaintenancePage> {
  final _titleCtrl = TextEditingController();
  DateTime? _date;
  String? _vehicleId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    context.read<VehiclesBloc>().add(const VehiclesLoadRequested());
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _titleCtrl.text.trim().isNotEmpty && _date != null && _vehicleId != null;

  @override
  Widget build(BuildContext context) {
    return BlocListener<MaintenanceBloc, MaintenanceState>(
      listenWhen: (prev, curr) => _submitting && prev.loading == true && curr.loading == false,
      listener: (context, state) {
        setState(() => _submitting = false);
        final err = state.error?.trim();
        if (err != null && err.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err), backgroundColor: AppColors.danger),
          );
          return;
        }
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
          title: Text(
            'Set Maintenance Reminder',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _titleCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Service title (e.g. Oil Change)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                _VehicleField(
                  vehicleId: _vehicleId,
                  onTap: _submitting
                      ? () {}
                      : () async {
                          final id = await _pickVehicleId(context);
                          if (!mounted) return;
                          if (id == null) return;
                          setState(() => _vehicleId = id);
                        },
                ),
                const SizedBox(height: Spacing.md),
                _DateField(
                  date: _date,
                  onTap: _submitting
                      ? () {}
                      : () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _date ?? now.add(const Duration(days: 1)),
                            firstDate: now,
                            lastDate: now.add(const Duration(days: 365)),
                          );
                          if (!mounted) return;
                          if (picked == null) return;
                          setState(() => _date = picked);
                        },
                ),
                const Spacer(),
                BlocBuilder<MaintenanceBloc, MaintenanceState>(
                  builder: (context, state) {
                    final busy = _submitting || state.loading;
                    return ElevatedButton(
                      onPressed: (!_canSubmit || busy)
                          ? null
                          : () {
                              setState(() => _submitting = true);
                              context.read<MaintenanceBloc>().add(
                                    MaintenanceUpcomingCreateRequested(
                                      title: _titleCtrl.text.trim(),
                                      scheduledAt: DateTime(_date!.year, _date!.month, _date!.day),
                                      vehicleId: _vehicleId!,
                                    ),
                                  );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.border,
                        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Add'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _pickVehicleId(BuildContext context) async {
    final bloc = context.read<VehiclesBloc>();
    bloc.add(const VehiclesLoadRequested());

    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return BlocProvider.value(
          value: bloc,
          child: SafeArea(
            top: false,
            child: BlocBuilder<VehiclesBloc, VehiclesState>(
              builder: (context, state) {
                if (state is VehiclesLoading || state is VehiclesInitial) {
                  return const Center(child: Padding(padding: EdgeInsets.all(Spacing.lg), child: CircularProgressIndicator()));
                }
                final vehicles = state is VehiclesLoaded ? state.vehicles : const <Vehicle>[];
                if (vehicles.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.lg),
                      child: Text(
                        'No vehicles found. Add a vehicle first.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(Spacing.lg),
                  itemCount: vehicles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
                  itemBuilder: (ctx, i) {
                    final v = vehicles[i];
                    return ListTile(
                      leading: const Icon(Icons.directions_car_outlined),
                      title: Text(v.displayName),
                      subtitle: Text(v.plateNumber),
                      onTap: () => Navigator.of(ctx).pop(v.id),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _VehicleField extends StatelessWidget {
  const _VehicleField({required this.vehicleId, required this.onTap});
  final String? vehicleId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VehiclesBloc>().state;
    final vehicles = state is VehiclesLoaded ? state.vehicles : const <Vehicle>[];
    final selected = vehicles.where((v) => v.id == vehicleId).cast<Vehicle?>().firstOrNull;
    final text = selected != null ? '${selected.displayName} (${selected.plateNumber})' : 'Select vehicle';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
        child: InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          child: Text(
            text,
            style: selected == null
                ? AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)
                : AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});
  final DateTime? date;
  final VoidCallback onTap;

  static String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = months[d.month - 1];
    return '$m ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final value = date == null ? 'Select date' : _formatDate(date!);
    final isEmpty = date == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
        child: InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          child: Text(
            value,
            style: isEmpty
                ? AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)
                : AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

