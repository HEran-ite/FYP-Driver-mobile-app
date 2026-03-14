library;

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import '../../application/usecases/add_vehicle_usecase.dart';
import '../../application/usecases/delete_vehicle_usecase.dart';
import '../../application/usecases/get_vehicle_usecase.dart';
import '../../application/usecases/list_vehicles_usecase.dart';
import '../../application/usecases/update_vehicle_usecase.dart';
import 'vehicles_event.dart';
import 'vehicles_state.dart';

class VehiclesBloc extends Bloc<VehiclesEvent, VehiclesState> {
  VehiclesBloc({
    required ListVehiclesUseCase listVehiclesUseCase,
    required GetVehicleUseCase getVehicleUseCase,
    required AddVehicleUseCase addVehicleUseCase,
    required UpdateVehicleUseCase updateVehicleUseCase,
    required DeleteVehicleUseCase deleteVehicleUseCase,
  })  : _list = listVehiclesUseCase,
        _get = getVehicleUseCase,
        _add = addVehicleUseCase,
        _update = updateVehicleUseCase,
        _delete = deleteVehicleUseCase,
        super(const VehiclesInitial()) {
    on<VehiclesLoadRequested>(_onLoad);
    on<VehicleDetailRequested>(_onDetail);
    on<VehicleDeleteRequested>(_onDelete);
    on<VehicleAddRequested>(_onAdd);
    on<VehicleUpdateRequested>(_onUpdate);
  }

  final ListVehiclesUseCase _list;
  final GetVehicleUseCase _get;
  final AddVehicleUseCase _add;
  final UpdateVehicleUseCase _update;
  final DeleteVehicleUseCase _delete;

  Future<void> _onLoad(VehiclesLoadRequested event, Emitter<VehiclesState> emit) async {
    emit(const VehiclesLoading());
    try {
      final vehicles = await _list();
      emit(VehiclesLoaded(vehicles));
    } catch (e) {
      // If endpoint not found (404), show empty list so screen is still usable
      if (e is DioException && e.response?.statusCode == 404) {
        emit(const VehiclesLoaded([]));
        return;
      }
      emit(VehiclesFailure(_message(e)));
    }
  }

  Future<void> _onDetail(VehicleDetailRequested event, Emitter<VehiclesState> emit) async {
    emit(const VehiclesLoading());
    try {
      final vehicle = await _get(event.id);
      emit(VehicleDetailLoaded(vehicle));
    } catch (e) {
      emit(VehiclesFailure(_message(e)));
    }
  }

  Future<void> _onDelete(VehicleDeleteRequested event, Emitter<VehiclesState> emit) async {
    final current = state;
    final isFromDetail = current is VehicleDetailLoaded;
    final list = current is VehiclesLoaded ? current.vehicles : null;
    if (!isFromDetail && list == null) return;

    emit(const VehiclesLoading());
    try {
      await _delete(event.id);
      if (isFromDetail) {
        emit(VehicleDeleted(event.id));
      } else if (list != null) {
        final updated = list.where((v) => v.id != event.id).toList();
        emit(VehiclesLoaded(updated));
      }
    } catch (e) {
      emit(VehiclesFailure(_message(e)));
      emit(current);
    }
  }

  Future<void> _onAdd(VehicleAddRequested event, Emitter<VehiclesState> emit) async {
    emit(const VehiclesLoading());
    try {
      final vehicle = await _add(
        make: event.make,
        model: event.model,
        year: event.year,
        plateNumber: event.plateNumber,
        type: event.type,
        color: event.color,
        vin: event.vin,
        mileage: event.mileage,
        fuelType: event.fuelType,
        insuranceExpiresAt: event.insuranceExpiresAt,
        registrationExpiresAt: event.registrationExpiresAt,
        insuranceFilePath: event.insuranceFilePath,
        registrationFilePath: event.registrationFilePath,
      );
      emit(VehicleActionSuccess(vehicle));
    } catch (e) {
      emit(VehiclesFailure(_message(e)));
    }
  }

  Future<void> _onUpdate(VehicleUpdateRequested event, Emitter<VehiclesState> emit) async {
    emit(const VehiclesLoading());
    try {
      final vehicle = await _update(
        id: event.id,
        make: event.make,
        model: event.model,
        year: event.year,
        plateNumber: event.plateNumber,
        type: event.type,
        color: event.color,
        vin: event.vin,
        mileage: event.mileage,
        fuelType: event.fuelType,
        insuranceExpiresAt: event.insuranceExpiresAt,
        registrationExpiresAt: event.registrationExpiresAt,
        insuranceFilePath: event.insuranceFilePath,
        registrationFilePath: event.registrationFilePath,
      );
      emit(VehicleActionSuccess(vehicle));
    } catch (e) {
      emit(VehiclesFailure(_message(e)));
    }
  }

  String _message(dynamic e) {
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      if (data is Map && data['error'] != null) return data['error'].toString();
      if (data is Map && data['message'] != null) return data['message'].toString();
      if (statusCode != null) {
        if (statusCode == 404) return 'Vehicles API not found (404). Backend may use /drivers/vehicles or /driver/vehicles.';
        if (statusCode >= 500) return 'Server error ($statusCode). Try again later.';
      }
      final msg = e.message?.toString() ?? e.type.toString();
      if (msg.isNotEmpty && msg != 'null') return msg;
    }
    final s = e.toString();
    if (s.contains('SocketException') || s.contains('Connection') || s.contains('Failed host lookup')) {
      return 'Cannot reach server. Check backend is running and base URL.';
    }
    if (s.length < 120) return s;
    return 'Something went wrong.';
  }
}
