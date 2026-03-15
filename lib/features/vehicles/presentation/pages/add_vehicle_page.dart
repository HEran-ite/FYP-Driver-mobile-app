library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/service_locator.dart';
import '../../domain/entities/vehicle.dart';
import '../bloc/vehicles_bloc.dart';
import '../bloc/vehicles_event.dart';
import '../bloc/vehicles_state.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key, this.editVehicle});

  final Vehicle? editVehicle;

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  static const int _totalSteps = 4;
  int _step = 0;

  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _vinCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _insuranceExpiryCtrl = TextEditingController();
  final _registrationExpiryCtrl = TextEditingController();
  String? _fuelType;
  String? _selectedInsuranceFileName;
  String? _selectedRegistrationFileName;
  String? _selectedInsurancePath;
  String? _selectedRegistrationPath;

  static const List<String> fuelTypes = ['Gasoline', 'Diesel', 'Electric', 'Hybrid', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.editVehicle != null) {
      final v = widget.editVehicle!;
      _makeCtrl.text = v.make;
      _modelCtrl.text = v.model;
      _yearCtrl.text = v.year > 0 ? v.year.toString() : '';
      _plateCtrl.text = v.plateNumber;
      _vinCtrl.text = v.vin ?? '';
      _mileageCtrl.text = v.mileage != null ? v.mileage.toString() : '';
      _typeCtrl.text = v.type ?? '';
      _colorCtrl.text = v.color ?? '';
      _fuelType = v.fuelType;
      if (v.insuranceExpiresAt != null) {
        _insuranceExpiryCtrl.text = _formatDate(v.insuranceExpiresAt!);
      }
      if (v.registrationExpiresAt != null) {
        _registrationExpiryCtrl.text = _formatDate(v.registrationExpiresAt!);
      }
    }
  }

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate(BuildContext context, TextEditingController ctrl) async {
    final initial = DateTime.tryParse(ctrl.text);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => ctrl.text = _formatDate(picked));
    }
  }

  Future<void> _pickInsuranceFile() async {
    if (!mounted) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: false,
      );
      if (!mounted) return;
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        final name = file.name;
        if (name.isNotEmpty) {
          setState(() {
            _selectedInsuranceFileName = name;
            _selectedInsurancePath = file.path;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected: $name'), behavior: SnackBarBehavior.floating),
            );
          }
        }
      }
    } catch (e, st) {
      debugPrint('Insurance file pick error: $e $st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file picker: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickRegistrationFile() async {
    if (!mounted) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: false,
      );
      if (!mounted) return;
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        final name = file.name;
        if (name.isNotEmpty) {
          setState(() {
            _selectedRegistrationFileName = name;
            _selectedRegistrationPath = file.path;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected: $name'), behavior: SnackBarBehavior.floating),
            );
          }
        }
      }
    } catch (e, st) {
      debugPrint('Registration file pick error: $e $st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file picker: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _plateCtrl.dispose();
    _vinCtrl.dispose();
    _mileageCtrl.dispose();
    _typeCtrl.dispose();
    _colorCtrl.dispose();
    _insuranceExpiryCtrl.dispose();
    _registrationExpiryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editVehicle != null;

    return BlocProvider(
      create: (_) => getIt<VehiclesBloc>(),
      child: BlocConsumer<VehiclesBloc, VehiclesState>(
        listenWhen: (prev, curr) =>
            curr is VehicleActionSuccess || curr is VehiclesFailure,
        listener: (context, state) {
          if (state is VehicleActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEdit ? 'Vehicle updated.' : 'Vehicle added successfully.'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop();
          }
          if (state is VehiclesFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              isEdit ? 'Edit Vehicle' : 'Add Vehicle',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            bottom: isEdit
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(56),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _stepTitle(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: Spacing.xs),
                          Row(
                            children: List.generate(
                              _totalSteps,
                              (i) => Expanded(
                                child: Container(
                                  height: 4,
                                  margin: const EdgeInsets.only(right: 2),
                                  decoration: BoxDecoration(
                                    color: i <= _step
                                        ? AppColors.secondary
                                        : AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          body: isEdit
              ? _EditForm(
                  makeCtrl: _makeCtrl,
                  modelCtrl: _modelCtrl,
                  yearCtrl: _yearCtrl,
                  plateCtrl: _plateCtrl,
                  vinCtrl: _vinCtrl,
                  mileageCtrl: _mileageCtrl,
                  typeCtrl: _typeCtrl,
                  colorCtrl: _colorCtrl,
                  insuranceExpiryCtrl: _insuranceExpiryCtrl,
                  registrationExpiryCtrl: _registrationExpiryCtrl,
                  fuelType: _fuelType,
                  onFuelType: (v) => setState(() => _fuelType = v),
                  onPickInsuranceExpiry: () => _pickDate(context, _insuranceExpiryCtrl),
                  onPickRegistrationExpiry: () => _pickDate(context, _registrationExpiryCtrl),
                  onUploadInsurance: _pickInsuranceFile,
                  onUploadRegistration: _pickRegistrationFile,
                  selectedInsuranceName: _selectedInsuranceFileName,
                  selectedRegistrationName: _selectedRegistrationFileName,
                  onSave: () => _submit(context),
                )
              : _step == 0
                  ? _Step1Basic(
                      makeCtrl: _makeCtrl,
                      modelCtrl: _modelCtrl,
                      yearCtrl: _yearCtrl,
                      plateCtrl: _plateCtrl,
                      onNext: () => setState(() => _step = 1),
                    )
                  : _step == 1
                      ? _Step2Technical(
                          vinCtrl: _vinCtrl,
                          mileageCtrl: _mileageCtrl,
                          colorCtrl: _colorCtrl,
                          fuelType: _fuelType,
                          onFuelType: (v) => setState(() => _fuelType = v),
                          onNext: () => setState(() => _step = 2),
                          onBack: () => setState(() => _step = 0),
                        )
                      : _step == 2
                          ? _Step3Upload(
                              onNext: () => setState(() => _step = 3),
                              onBack: () => setState(() => _step = 1),
                              onUploadInsurance: _pickInsuranceFile,
                              onUploadRegistration: _pickRegistrationFile,
                              selectedInsuranceName: _selectedInsuranceFileName,
                              selectedRegistrationName: _selectedRegistrationFileName,
                            )
                          : _Step4Confirm(
                              make: _makeCtrl.text.trim(),
                              model: _modelCtrl.text.trim(),
                              year: _yearCtrl.text.trim(),
                              plate: _plateCtrl.text.trim(),
                              color: _colorCtrl.text.trim(),
                              vin: _vinCtrl.text.trim(),
                              mileage: _mileageCtrl.text.trim(),
                              fuelType: _fuelType,
                              onAdd: () => _submit(context),
                              onEditDetails: () => setState(() => _step = 0),
                            ),
        ),
      ),
    );
  }

  String _stepTitle() {
    switch (_step) {
      case 0:
        return 'Step 1 of 4: Basic Information';
      case 1:
        return 'Step 2 of 4: Technical Details';
      case 2:
        return 'Step 3 of 4: Upload Documents';
      case 3:
        return 'Step 4 of 4: Confirm Details';
      default:
        return '';
    }
  }

  void _submit(BuildContext context) {
    final make = _makeCtrl.text.trim();
    final model = _modelCtrl.text.trim();
    final year = int.tryParse(_yearCtrl.text.trim()) ?? 0;
    final plate = _plateCtrl.text.trim();
    final vin = _vinCtrl.text.trim().isEmpty ? null : _vinCtrl.text.trim();
    final mileage = int.tryParse(_mileageCtrl.text.trim());

    if (make.isEmpty || model.isEmpty || plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill Make, Model and License Plate.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final type = _typeCtrl.text.trim().isEmpty ? null : _typeCtrl.text.trim();
    final color = _colorCtrl.text.trim().isEmpty ? null : _colorCtrl.text.trim();

    final insuranceExpiry = DateTime.tryParse(_insuranceExpiryCtrl.text.trim());
    final registrationExpiry = DateTime.tryParse(_registrationExpiryCtrl.text.trim());

    if (widget.editVehicle != null) {
      context.read<VehiclesBloc>().add(
            VehicleUpdateRequested(
              id: widget.editVehicle!.id,
              make: make,
              model: model,
              year: year > 0 ? year : null,
              plateNumber: plate,
              type: type,
              color: color,
              vin: vin,
              mileage: mileage,
              fuelType: _fuelType,
              insuranceExpiresAt: insuranceExpiry,
              registrationExpiresAt: registrationExpiry,
              insuranceFilePath: _selectedInsurancePath,
              registrationFilePath: _selectedRegistrationPath,
            ),
          );
    } else {
      context.read<VehiclesBloc>().add(
            VehicleAddRequested(
              make: make,
              model: model,
              year: year > 0 ? year : DateTime.now().year,
              plateNumber: plate,
              type: type,
              color: color,
              vin: vin,
              mileage: mileage,
              fuelType: _fuelType,
              insuranceExpiresAt: insuranceExpiry,
              registrationExpiresAt: registrationExpiry,
              insuranceFilePath: _selectedInsurancePath,
              registrationFilePath: _selectedRegistrationPath,
            ),
          );
    }
  }
}

class _EditForm extends StatelessWidget {
  const _EditForm({
    required this.makeCtrl,
    required this.modelCtrl,
    required this.yearCtrl,
    required this.plateCtrl,
    required this.vinCtrl,
    required this.mileageCtrl,
    required this.typeCtrl,
    required this.colorCtrl,
    required this.insuranceExpiryCtrl,
    required this.registrationExpiryCtrl,
    required this.fuelType,
    required this.onFuelType,
    required this.onPickInsuranceExpiry,
    required this.onPickRegistrationExpiry,
    required this.onUploadInsurance,
    required this.onUploadRegistration,
    this.selectedInsuranceName,
    this.selectedRegistrationName,
    required this.onSave,
  });

  final TextEditingController makeCtrl;
  final TextEditingController modelCtrl;
  final TextEditingController yearCtrl;
  final TextEditingController plateCtrl;
  final TextEditingController vinCtrl;
  final TextEditingController mileageCtrl;
  final TextEditingController typeCtrl;
  final TextEditingController colorCtrl;
  final TextEditingController insuranceExpiryCtrl;
  final TextEditingController registrationExpiryCtrl;
  final String? fuelType;
  final ValueChanged<String?> onFuelType;
  final VoidCallback onPickInsuranceExpiry;
  final VoidCallback onPickRegistrationExpiry;
  final VoidCallback onUploadInsurance;
  final VoidCallback onUploadRegistration;
  final String? selectedInsuranceName;
  final String? selectedRegistrationName;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Update vehicle information.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: Spacing.lg),
          _TextField(controller: makeCtrl, label: 'Make'),
          const SizedBox(height: Spacing.md),
          _TextField(controller: modelCtrl, label: 'Model'),
          const SizedBox(height: Spacing.md),
          _TextField(controller: yearCtrl, label: 'Year', keyboardType: TextInputType.number),
          const SizedBox(height: Spacing.md),
          _TextField(controller: plateCtrl, label: 'License Plate'),
          const SizedBox(height: Spacing.md),
          _TextField(controller: typeCtrl, label: 'Type', hint: 'e.g., Sedan, SUV'),
          const SizedBox(height: Spacing.md),
          _TextField(controller: colorCtrl, label: 'Color', hint: 'e.g., Black, White'),
          const SizedBox(height: Spacing.md),
          _TextField(controller: vinCtrl, label: 'VIN'),
          const SizedBox(height: Spacing.md),
          _TextField(controller: mileageCtrl, label: 'Current Mileage', keyboardType: TextInputType.number),
          const SizedBox(height: Spacing.md),
          _DateField(
            controller: insuranceExpiryCtrl,
            label: 'Insurance expiry',
            onTap: onPickInsuranceExpiry,
          ),
          const SizedBox(height: Spacing.md),
          _DateField(
            controller: registrationExpiryCtrl,
            label: 'Registration expiry',
            onTap: onPickRegistrationExpiry,
          ),
          const SizedBox(height: Spacing.md),
          _UploadCard(
            title: 'Insurance Card',
            subtitle: 'Upload or replace Insurance Card',
            hint: 'PDF, JPG, PNG Max 5MB',
            onTap: onUploadInsurance,
            selectedFileName: selectedInsuranceName,
          ),
          const SizedBox(height: Spacing.md),
          _UploadCard(
            title: 'Registration Document',
            subtitle: 'Upload or replace Registration',
            hint: 'PDF, JPG, PNG Max 5MB',
            onTap: onUploadRegistration,
            selectedFileName: selectedRegistrationName,
          ),
          const SizedBox(height: Spacing.md),
          DropdownButtonFormField<String>(
            value: fuelType,
            decoration: InputDecoration(
              labelText: 'Fuel Type',
              hintText: 'Select fuel type',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(BorderRadiusValues.input)),
              filled: true,
              fillColor: AppColors.surface,
            ),
            items: _AddVehiclePageState.fuelTypes
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: onFuelType,
          ),
          const SizedBox(height: Spacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: Spacing.md),
              ),
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step1Basic extends StatelessWidget {
  const _Step1Basic({
    required this.makeCtrl,
    required this.modelCtrl,
    required this.yearCtrl,
    required this.plateCtrl,
    required this.onNext,
  });

  final TextEditingController makeCtrl;
  final TextEditingController modelCtrl;
  final TextEditingController yearCtrl;
  final TextEditingController plateCtrl;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TextField(controller: makeCtrl, label: 'Make', hint: 'e.g., Honda'),
          const SizedBox(height: Spacing.md),
          _TextField(controller: modelCtrl, label: 'Model', hint: 'e.g., Civic'),
          const SizedBox(height: Spacing.md),
          _TextField(controller: yearCtrl, label: 'Year', hint: 'e.g., 2020', keyboardType: TextInputType.number),
          const SizedBox(height: Spacing.md),
          _TextField(controller: plateCtrl, label: 'License Plate', hint: 'e.g., ABC 123'),
          const SizedBox(height: Spacing.xl),
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: Spacing.md),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class _Step2Technical extends StatelessWidget {
  const _Step2Technical({
    required this.vinCtrl,
    required this.mileageCtrl,
    required this.colorCtrl,
    required this.fuelType,
    required this.onFuelType,
    required this.onNext,
    required this.onBack,
  });

  final TextEditingController vinCtrl;
  final TextEditingController mileageCtrl;
  final TextEditingController colorCtrl;
  final String? fuelType;
  final ValueChanged<String?> onFuelType;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TextField(controller: vinCtrl, label: 'VIN (Vehicle Identification Number)', hint: '17-character VIN'),
          const SizedBox(height: Spacing.md),
          _TextField(controller: mileageCtrl, label: 'Current Mileage', hint: 'e.g., 45000', keyboardType: TextInputType.number),
          const SizedBox(height: Spacing.md),
          _TextField(controller: colorCtrl, label: 'Color', hint: 'e.g., Black, White'),
          const SizedBox(height: Spacing.md),
          DropdownButtonFormField<String>(
            value: fuelType,
            decoration: InputDecoration(
              labelText: 'Fuel Type',
              hintText: 'Select fuel type',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(BorderRadiusValues.input)),
              filled: true,
              fillColor: AppColors.surface,
            ),
            items: _AddVehiclePageState.fuelTypes
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: onFuelType,
          ),
          const SizedBox(height: Spacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: Spacing.md)),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Step3Upload extends StatelessWidget {
  const _Step3Upload({
    required this.onNext,
    required this.onBack,
    required this.onUploadInsurance,
    required this.onUploadRegistration,
    this.selectedInsuranceName,
    this.selectedRegistrationName,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onUploadInsurance;
  final VoidCallback onUploadRegistration;
  final String? selectedInsuranceName;
  final String? selectedRegistrationName;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _UploadCard(
            title: 'Insurance Card',
            subtitle: 'Upload Insurance Card',
            hint: 'PDF, JPG, PNG Max 5MB',
            onTap: onUploadInsurance,
            selectedFileName: selectedInsuranceName,
          ),
          const SizedBox(height: Spacing.lg),
          _UploadCard(
            title: 'Registration Document',
            subtitle: 'Upload Registration',
            hint: 'PDF, JPG, PNG Max 5MB',
            onTap: onUploadRegistration,
            selectedFileName: selectedRegistrationName,
          ),
          const SizedBox(height: Spacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: Spacing.md)),
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.onTap,
    this.selectedFileName,
  });

  final String title;
  final String subtitle;
  final String hint;
  final VoidCallback onTap;
  final String? selectedFileName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimary)),
          if (selectedFileName != null) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              'Selected: $selectedFileName',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.success, fontSize: 12),
            ),
          ],
          const SizedBox(height: Spacing.md),
          Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
          Text(hint, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: Spacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.upload_file, size: 20),
              label: const Text('Select file'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: Spacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.controller, required this.label, required this.onTap});

  final TextEditingController controller;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: IgnorePointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: 'Tap to pick date',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(BorderRadiusValues.input)),
            filled: true,
            fillColor: AppColors.surface,
            suffixIcon: const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 20),
          ),
        ),
      ),
    );
  }
}

class _Step4Confirm extends StatelessWidget {
  const _Step4Confirm({
    required this.make,
    required this.model,
    required this.year,
    required this.plate,
    required this.color,
    required this.vin,
    required this.mileage,
    required this.fuelType,
    required this.onAdd,
    required this.onEditDetails,
  });

  final String make;
  final String model;
  final String year;
  final String plate;
  final String color;
  final String vin;
  final String mileage;
  final String? fuelType;
  final VoidCallback onAdd;
  final VoidCallback onEditDetails;

  @override
  Widget build(BuildContext context) {
    final mileageNum = int.tryParse(mileage);
    final mileageDisplay = mileageNum != null ? '$mileageNum miles' : (mileage.isEmpty ? '—' : '$mileage miles');
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vehicle Summary', style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: Spacing.md),
                _SummaryRow('Make', make.isEmpty ? '—' : make),
                _SummaryRow('Model', model.isEmpty ? '—' : model),
                _SummaryRow('Year', year.isEmpty ? '—' : year),
                _SummaryRow('Plate', plate.isEmpty ? '—' : plate),
                _SummaryRow('Color', color.isEmpty ? '—' : color),
                _SummaryRow('VIN', vin.isEmpty ? '—' : vin),
                _SummaryRow('Mileage', mileageDisplay),
                _SummaryRow('Fuel Type', fuelType ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
              border: Border.all(color: AppColors.success.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 28),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    'Ready to add this vehicle in your garage. You can edit details anytime.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: Spacing.md),
              ),
              child: const Text('Add Vehicle'),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onEditDetails,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                side: const BorderSide(color: AppColors.border),
              ),
              child: const Text('Edit Details'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(BorderRadiusValues.input)),
        filled: true,
        fillColor: AppColors.surface,
      ),
      keyboardType: keyboardType,
    );
  }
}
