import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../appointments/presentation/bloc/appointments_bloc.dart';
import '../../../appointments/presentation/bloc/appointments_event.dart';
import '../../../appointments/presentation/bloc/appointments_state.dart';
import '../../../vehicles/domain/entities/vehicle.dart';
import '../../../vehicles/presentation/bloc/vehicles_bloc.dart';
import '../../../vehicles/presentation/bloc/vehicles_event.dart';
import '../../../vehicles/presentation/bloc/vehicles_state.dart';
import '../../domain/entities/service_center.dart';
import '../../../../injection/service_locator.dart';
import '../widgets/service_text_formatter.dart';

import 'service_locator_page.dart';

class BookServiceWizardPage extends StatefulWidget {
  const BookServiceWizardPage({
    super.key,
    required this.center,
    this.isOnsite = false,
    this.serviceLatitude,
    this.serviceLongitude,
  });

  final ServiceCenter center;

  /// On-site flow: same booking API with [isOnsite] and driver coordinates as service location.
  final bool isOnsite;
  final double? serviceLatitude;
  final double? serviceLongitude;

  @override
  State<BookServiceWizardPage> createState() => _BookServiceWizardPageState();
}

enum _WizardStep {
  selectVehicle,
  selectServices,
  pickDateTime,
}

class _BookServiceWizardPageState extends State<BookServiceWizardPage> {
  _WizardStep _step = _WizardStep.selectVehicle;
  late final AppointmentsBloc _appointmentsBloc;
  late final VehiclesBloc _vehiclesBloc;
  late final ApiClient _apiClient;

  bool _isBooking = false;
  Appointment? _bookedAppointment;

  String? _selectedVehicleId;
  String? _selectedServiceDescription;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<GarageAvailabilitySlot> _availabilitySlots = const [];
  bool _availabilityLoading = true;

  bool get _step1Ready => _selectedVehicleId != null;
  bool get _step2Ready => _selectedServiceDescription != null;
  bool get _step3Ready => _availabilitySlots.isNotEmpty && _selectedDate != null && _selectedTime != null;

  @override
  void initState() {
    super.initState();
    _appointmentsBloc = getIt<AppointmentsBloc>()
      ..add(const AppointmentsLoadRequested());
    _vehiclesBloc = getIt<VehiclesBloc>()..add(const VehiclesLoadRequested());
    _apiClient = getIt<ApiClient>();
    _fetchGarageAvailability();
  }

  Future<void> _fetchGarageAvailability() async {
    setState(() => _availabilityLoading = true);
    try {
      final res = await _apiClient.dio.get<List<dynamic>>(
        ApiEndpoints.garageAvailabilitySlots(widget.center.id),
      );
      final data = res.data ?? const [];
      final slots = data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map(
            (json) => GarageAvailabilitySlot(
              dayOfWeek: json['dayOfWeek']?.toString() ?? 'MONDAY',
              startMinute: _toInt(json['startMinute']),
              endMinute: _toInt(json['endMinute']),
            ),
          )
          .where((s) => s.endMinute > s.startMinute)
          .toList();

      if (!mounted) return;
      setState(() {
        _availabilitySlots = slots;
        _availabilityLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _availabilitySlots = const [];
        _availabilityLoading = false;
      });
      final message = (e.response?.data is Map &&
              (e.response?.data as Map)['error'] != null)
          ? (e.response?.data as Map)['error'].toString()
          : 'Unable to load garage availability';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _availabilitySlots = const [];
        _availabilityLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load garage availability')),
      );
    }
  }

  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _appointmentsBloc),
        BlocProvider.value(value: _vehiclesBloc),
      ],
      child: BlocListener<AppointmentsBloc, AppointmentsState>(
        listener: (context, state) {
          if (state is AppointmentActionSuccess) {
            setState(() {
              _isBooking = false;
              _bookedAppointment = state.appointment;
            });
          }
          if (state is AppointmentsFailure) {
            setState(() {
              _isBooking = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: _bookedAppointment != null
              ? _SuccessView(
                  appointment: _bookedAppointment!,
                  isOnsite: widget.isOnsite,
                )
              : _WizardBody(),
        ),
        ),
      ),
    );
  }

  Widget _WizardBody() {
    final stepIndex = _step == _WizardStep.selectVehicle
        ? 1
        : _step == _WizardStep.selectServices
            ? 2
            : 3;
    final stepTitle = _step == _WizardStep.selectVehicle
        ? 'Select Vehicle'
        : _step == _WizardStep.selectServices
            ? 'Select Services'
            : 'Pick Date & Time';
    final flowTitle = widget.isOnsite ? 'On-site Service' : 'Book Service';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.md,
            Spacing.lg,
            0,
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      flowTitle,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Step $stepIndex of 3: $stepTitle',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                    SizedBox(
                      width: 240,
                      child: _StepIndicator(step: _step),
                    ),
                    const SizedBox(height: Spacing.lg),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _step == _WizardStep.selectVehicle
                ? _SelectVehicleStep()
                : _step == _WizardStep.selectServices
                    ? _SelectServicesStep()
                    : _PickDateTimeStep(),
          ),
        ),
      ],
    );
  }

  void _nextStep() {
    if (_step == _WizardStep.selectVehicle && !_step1Ready) return;
    if (_step == _WizardStep.selectServices && !_step2Ready) return;
    if (_step == _WizardStep.pickDateTime && !_step3Ready) return;

    setState(() {
      if (_step == _WizardStep.selectVehicle) {
        _step = _WizardStep.selectServices;
      } else if (_step == _WizardStep.selectServices) {
        _step = _WizardStep.pickDateTime;
        final firstDate = _nextAvailableDate(DateTime.now());
        if (firstDate != null) {
          _selectedDate = DateTime(firstDate.year, firstDate.month, firstDate.day);
          final times = _timeSlotsForDate(_selectedDate!);
          if (times.isNotEmpty) {
            _selectedTime = times.first;
          }
        }
      }
    });
  }

  Future<void> _confirmBooking() async {
    if (_selectedVehicleId == null || _selectedDate == null || _selectedTime == null) return;

    if (widget.isOnsite) {
      final lat = widget.serviceLatitude;
      final lng = widget.serviceLongitude;
      if (lat == null || lng == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your location is required for on-site service. Enable location and try again.',
            ),
          ),
        );
        return;
      }
    }

    final date = _selectedDate!;
    final time = _selectedTime!;
    final scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final description = (_selectedServiceDescription ?? widget.center.services.firstOrNull ?? 'Service').trim();

    if (_isBooking) return;
    setState(() => _isBooking = true);
    _appointmentsBloc.add(
          AppointmentBookRequested(
            garageId: widget.center.id,
            vehicleId: _selectedVehicleId!,
            scheduledAt: scheduledAt,
            serviceDescription: description,
            isOnsite: widget.isOnsite,
            serviceLatitude: widget.serviceLatitude,
            serviceLongitude: widget.serviceLongitude,
          ),
        );
  }

  @override
  void dispose() {
    _appointmentsBloc.close();
    _vehiclesBloc.close();
    super.dispose();
  }

  Widget _SelectVehicleStep() {
    return BlocBuilder<VehiclesBloc, VehiclesState>(
      builder: (context, state) {
        if (state is VehiclesLoading || state is VehiclesInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is VehiclesFailure) {
          return Center(child: Text(state.message));
        }
        final vehicles = state is VehiclesLoaded ? state.vehicles : <Vehicle>[];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: vehicles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
                  itemBuilder: (context, index) {
                    final v = vehicles[index];
                    final selected = v.id == _selectedVehicleId;
                    return _VehicleSelectCard(
                      vehicle: v,
                      selected: selected,
                      onTap: () => setState(() => _selectedVehicleId = v.id),
                    );
                  },
                ),
              ),
              const SizedBox(height: Spacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _step1Ready ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _step1Ready ? AppColors.secondary : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: Spacing.lg),
            ],
          ),
        );
      },
    );
  }

  Widget _SelectServicesStep() {
    final services = widget.center.services;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Column(
        children: [
          if (services.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: Text(
                'No services available for this garage right now.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: services.length,
              separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
              itemBuilder: (context, index) {
                final s = services[index];
                final selected = s == _selectedServiceDescription;
                return _ServiceSelectCard(
                  label: s,
                  selected: selected,
                  onTap: () => setState(() => _selectedServiceDescription = s),
                );
              },
            ),
          ),
          const SizedBox(height: Spacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _step2Ready ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _step2Ready ? AppColors.secondary : Colors.grey.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
                ),
              ),
              child: const Text('Continue'),
            ),
          ),
          const SizedBox(height: Spacing.lg),
        ],
      ),
    );
  }

  Widget _PickDateTimeStep() {
    final hasSlots = _availabilitySlots.isNotEmpty;
    final timeSlots = _selectedDate != null
        ? _timeSlotsForDate(_selectedDate!)
        : const <TimeOfDay>[];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Spacing.md),
          if (widget.isOnsite)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.home_repair_service, color: AppColors.secondary, size: 22),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      'Service location will be sent as your current position when you requested on-site service.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_availabilityLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: Spacing.md),
                child: CircularProgressIndicator(),
              ),
            ),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary),
              const SizedBox(width: Spacing.sm),
              Text(
                'Select Date',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          _PickerField(
            value: _selectedDate != null ? '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}' : '',
            enabled: hasSlots && !_availabilityLoading,
            onTap: () async {
              final now = DateTime.now();
              final first = DateTime(now.year, now.month, now.day);
              final initial = _selectedDate ?? _nextAvailableDate(first) ?? first;
              final picked = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: first,
                lastDate: first.add(const Duration(days: 365)),
                selectableDayPredicate: (d) {
                  return _isDateAvailable(d);
                },
              );
              if (picked == null) return;
              setState(() {
                _selectedDate = DateTime(picked.year, picked.month, picked.day);
                final slots = _timeSlotsForDate(_selectedDate!);
                if (slots.isEmpty) {
                  _selectedTime = null;
                } else if (_selectedTime == null ||
                    !slots.any((t) => t.hour == _selectedTime!.hour && t.minute == _selectedTime!.minute)) {
                  _selectedTime = slots.first;
                }
              });
            },
          ),
          const SizedBox(height: Spacing.lg),
          Row(
            children: [
              const Icon(Icons.access_time_outlined, color: AppColors.textSecondary),
              const SizedBox(width: Spacing.sm),
              Text(
                'Select Time',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: timeSlots.map((t) {
              final isSelected = _selectedTime == t;
              return ChoiceChip(
                label: Text(_formatTimeOfDay(t)),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedTime = t),
                selectedColor: AppColors.secondary,
                backgroundColor: AppColors.surfaceMuted,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
          if (!hasSlots)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: Text(
                'This garage has no availability configured. Booking is unavailable.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ),
          if (_selectedDate != null && timeSlots.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: Text(
                'No available slots for selected date.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ),
          const SizedBox(height: Spacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _step3Ready ? _confirmBooking : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _step3Ready ? AppColors.secondary : Colors.grey.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
                ),
              ),
              child: Text(widget.isOnsite ? 'Confirm on-site request' : 'Confirm Booking'),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          if (_isBooking)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  static String _formatTimeOfDay(TimeOfDay t) {
    final hour = t.hour;
    final minute = t.minute;
    final am = hour < 12;
    final displayHour = am ? (hour == 0 ? 12 : hour) : (hour == 12 ? 12 : hour - 12);
    final mStr = minute.toString().padLeft(2, '0');
    return '${displayHour.toString()}:$mStr ${am ? 'AM' : 'PM'}';
  }

  DateTime? _nextAvailableDate(DateTime from) {
    final start = DateTime(from.year, from.month, from.day);
    for (int i = 0; i <= 365; i++) {
      final d = start.add(Duration(days: i));
      if (_isDateAvailable(d)) return d;
    }
    return null;
  }

  bool _isDateAvailable(DateTime date) {
    final slots = _availabilitySlots;
    if (slots.isEmpty) return false;
    final day = _dayName(date.weekday);
    return slots.any((s) => s.dayOfWeek.toUpperCase() == day && s.endMinute > s.startMinute);
  }

  List<TimeOfDay> _timeSlotsForDate(DateTime date) {
    final slots = _availabilitySlots;
    if (slots.isEmpty) return const [];
    final day = _dayName(date.weekday);
    final daySlots = slots
        .where((s) => s.dayOfWeek.toUpperCase() == day && s.endMinute > s.startMinute)
        .toList();
    if (daySlots.isEmpty) return const [];

    final times = <TimeOfDay>[];
    for (final s in daySlots) {
      // 60-minute slots aligned to hour.
      int minute = s.startMinute;
      while (minute + 60 <= s.endMinute) {
        final h = minute ~/ 60;
        final m = minute % 60;
        times.add(TimeOfDay(hour: h, minute: m));
        minute += 60;
      }
    }
    // Deduplicate.
    final uniq = <String, TimeOfDay>{};
    for (final t in times) {
      uniq['${t.hour}:${t.minute}'] = t;
    }
    final out = uniq.values.toList()
      ..sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
    return out;
  }

  String _dayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'MONDAY';
      case DateTime.tuesday:
        return 'TUESDAY';
      case DateTime.wednesday:
        return 'WEDNESDAY';
      case DateTime.thursday:
        return 'THURSDAY';
      case DateTime.friday:
        return 'FRIDAY';
      case DateTime.saturday:
        return 'SATURDAY';
      case DateTime.sunday:
      default:
        return 'SUNDAY';
    }
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final _WizardStep step;

  @override
  Widget build(BuildContext context) {
    int index = step == _WizardStep.selectVehicle
        ? 0
        : step == _WizardStep.selectServices
            ? 1
            : 2;

    return SizedBox(
      height: 8,
      child: Row(
        children: List.generate(3, (i) {
          final active = i <= index;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 2 ? Spacing.xs : 0),
              height: 6,
              decoration: BoxDecoration(
                color: active ? AppColors.secondary : AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _VehicleSelectCard extends StatelessWidget {
  const _VehicleSelectCard({
    required this.vehicle,
    required this.selected,
    required this.onTap,
  });

  final Vehicle vehicle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : AppColors.surface,
          borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
          border: Border.all(
            color: selected ? AppColors.secondary : AppColors.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.shadowMedium,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? AppColors.surfaceDark : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
              ),
              child: const Icon(
                Icons.directions_car_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.displayName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.textOnPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    vehicle.plateNumber,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: selected ? AppColors.textOnPrimary.withOpacity(0.8) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceSelectCard extends StatelessWidget {
  const _ServiceSelectCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  IconData _iconFor(String s) {
    final l = s.toLowerCase();
    if (l.contains('oil')) return Icons.opacity;
    if (l.contains('tire')) return Icons.settings_ethernet;
    if (l.contains('brake')) return Icons.speed;
    if (l.contains('engine') || l.contains('diagnos')) return Icons.engineering;
    return Icons.handyman_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryLight : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
              ),
              child: Icon(
                _iconFor(label),
                size: 22,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                formatServiceLabel(label),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  final String value;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.md,
          horizontal: Spacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          value.isEmpty ? ' ' : value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: value.isEmpty ? AppColors.textDisabled : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    required this.appointment,
    this.isOnsite = false,
  });

  final Appointment appointment;
  final bool isOnsite;

  @override
  Widget build(BuildContext context) {
    // Booking page has access to widget.center; we can derive basic info from appointment description.
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Spacing.lg),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, size: 66, color: Colors.white),
                  const SizedBox(height: Spacing.md),
                  Text(
                    isOnsite ? 'On-site request sent!' : 'Booking Confirmed!',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    isOnsite
                        ? 'The garage has your request with service at your location.'
                        : 'Your appointment has been successfully scheduled',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
                boxShadow: [
                  BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOnsite ? 'Request details' : 'Appointment Details',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  _DetailRow(icon: Icons.description_outlined, label: 'Service', value: appointment.serviceDescription),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date & Time',
                    value: _formatDateTime(appointment.scheduledAt),
                  ),
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: isOnsite
                        ? 'Your location (when requested)'
                        : (appointment.garageName ?? 'Garage'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/driver-dashboard', (r) => r.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BorderRadiusValues.xl)),
                ),
                child: const Text('Back to Home'),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AllUpcomingAppointmentsPage(
                        centers: [],
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  side: const BorderSide(color: AppColors.border),
                  foregroundColor: AppColors.secondary,
                ),
                child: const Text('View All Appointments'),
              ),
            ),
            const SizedBox(height: Spacing.lg),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: Spacing.xs),
                Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime dt) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final local = dt.toLocal();
  final month = months[local.month - 1];
  final day = local.day;
  final year = local.year;

  final h = local.hour;
  final m = local.minute;
  final am = h < 12;
  final hour12 = am ? (h == 0 ? 12 : h) : (h == 12 ? 12 : h - 12);
  final timeStr = '${hour12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} ${am ? 'AM' : 'PM'}';

  return '$month $day, $year at $timeStr';
}


