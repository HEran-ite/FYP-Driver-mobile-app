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
import '../../domain/entities/maintenance_history.dart';
import '../bloc/maintenance_bloc.dart';
import '../bloc/maintenance_event.dart';
import '../bloc/maintenance_state.dart';

class LogMaintenanceRecordPage extends StatefulWidget {
  const LogMaintenanceRecordPage({super.key, this.existing, this.preselectedVehicleId});

  final MaintenanceHistory? existing;
  final String? preselectedVehicleId;

  @override
  State<LogMaintenanceRecordPage> createState() => _LogMaintenanceRecordPageState();
}

class _LogMaintenanceRecordPageState extends State<LogMaintenanceRecordPage> {
  final _serviceCtrl = TextEditingController();
  final _garageCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  DateTime? _date;
  String? _vehicleId;
  bool _submitting = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _serviceCtrl.text = e.title;
      _garageCtrl.text = e.garageName ?? '';
      if (e.amount != null) _costCtrl.text = e.amount.toString();
      _date = DateTime(e.date.year, e.date.month, e.date.day);
      _vehicleId = e.vehicleId;
    } else {
      _vehicleId = widget.preselectedVehicleId;
      _date = DateTime.now();
    }
    context.read<VehiclesBloc>().add(const VehiclesLoadRequested());
  }

  @override
  void dispose() {
    _serviceCtrl.dispose();
    _garageCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _serviceCtrl.text.trim().isNotEmpty && _date != null;

  num? _parsedCost() {
    final t = _costCtrl.text.trim();
    if (t.isEmpty) return null;
    return num.tryParse(t.replaceAll(',', ''));
  }

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
            _isEdit ? 'Edit service record' : 'Log service',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _serviceCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Service name',
                    hintText: 'e.g. Oil change',
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
                          setState(() => _vehicleId = id);
                        },
                ),
                const SizedBox(height: Spacing.md),
                TextField(
                  controller: _garageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Garage / shop (optional)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
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
                            initialDate: _date ?? now,
                            firstDate: DateTime(now.year - 10),
                            lastDate: now.add(const Duration(days: 1)),
                          );
                          if (!mounted) return;
                          if (picked == null) return;
                          setState(() => _date = picked);
                        },
                ),
                const SizedBox(height: Spacing.md),
                TextField(
                  controller: _costCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Cost (optional)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: Spacing.xl),
                BlocBuilder<MaintenanceBloc, MaintenanceState>(
                  builder: (context, state) {
                    final busy = _submitting || state.loading;
                    return ElevatedButton(
                      onPressed: (!_canSubmit || busy)
                          ? null
                          : () {
                              setState(() => _submitting = true);
                              final vid = _vehicleId?.trim();
                              final garage = _garageCtrl.text.trim();
                              if (_isEdit) {
                                context.read<MaintenanceBloc>().add(
                                      MaintenanceHistoryUpdateRequested(
                                        id: widget.existing!.id,
                                        vehicleId: vid != null && vid.isNotEmpty ? vid : null,
                                        serviceName: _serviceCtrl.text.trim(),
                                        garageName: garage.isEmpty ? null : garage,
                                        serviceDate: DateTime(_date!.year, _date!.month, _date!.day),
                                        cost: _parsedCost(),
                                      ),
                                    );
                              } else {
                                context.read<MaintenanceBloc>().add(
                                      MaintenanceHistoryCreateRequested(
                                        vehicleId: vid != null && vid.isNotEmpty ? vid : null,
                                        serviceName: _serviceCtrl.text.trim(),
                                        garageName: garage.isEmpty ? null : garage,
                                        serviceDate: DateTime(_date!.year, _date!.month, _date!.day),
                                        cost: _parsedCost(),
                                      ),
                                    );
                              }
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
                          : Text(_isEdit ? 'Save' : 'Save record'),
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
                  return const Padding(
                    padding: EdgeInsets.all(Spacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final vehicles = state is VehiclesLoaded ? state.vehicles : const <Vehicle>[];
                return ListView(
                  padding: const EdgeInsets.all(Spacing.lg),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.link_off_outlined),
                      title: const Text('No vehicle'),
                      onTap: () => Navigator.of(ctx).pop(''),
                    ),
                    if (vehicles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                        child: Text(
                          'No vehicles registered yet.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      )
                    else
                      ...vehicles.map(
                        (v) => ListTile(
                          leading: const Icon(Icons.directions_car_outlined),
                          title: Text(v.displayName),
                          subtitle: Text(v.plateNumber),
                          onTap: () => Navigator.of(ctx).pop(v.id),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    ).then((id) {
      if (id == null) return null;
      if (id.isEmpty) return null;
      return id;
    });
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
    Vehicle? selected;
    for (final v in vehicles) {
      if (v.id == vehicleId) {
        selected = v;
        break;
      }
    }
    final text = selected != null ? '${selected.displayName} (${selected.plateNumber})' : 'Vehicle (optional)';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Vehicle',
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
    final value = date == null ? 'Service date' : _formatDate(date!);
    final isEmpty = date == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Service date',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          child: Text(
            isEmpty ? 'Select date' : value,
            style: isEmpty
                ? AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)
                : AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
