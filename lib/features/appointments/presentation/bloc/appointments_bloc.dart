library;

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import '../../application/usecases/book_appointment_usecase.dart';
import '../../application/usecases/cancel_appointment_usecase.dart';
import '../../application/usecases/list_appointments_usecase.dart';
import '../../application/usecases/reschedule_appointment_usecase.dart';
import 'appointments_event.dart';
import 'appointments_state.dart';

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  AppointmentsBloc({
    required ListAppointmentsUseCase listAppointmentsUseCase,
    required BookAppointmentUseCase bookAppointmentUseCase,
    required RescheduleAppointmentUseCase rescheduleAppointmentUseCase,
    required CancelAppointmentUseCase cancelAppointmentUseCase,
  })  : _list = listAppointmentsUseCase,
        _book = bookAppointmentUseCase,
        _reschedule = rescheduleAppointmentUseCase,
        _cancel = cancelAppointmentUseCase,
        super(const AppointmentsInitial()) {
    on<AppointmentsLoadRequested>(_onLoad);
    on<AppointmentBookRequested>(_onBook);
    on<AppointmentRescheduleRequested>(_onReschedule);
    on<AppointmentCancelRequested>(_onCancel);
  }

  final ListAppointmentsUseCase _list;
  final BookAppointmentUseCase _book;
  final RescheduleAppointmentUseCase _reschedule;
  final CancelAppointmentUseCase _cancel;

  Future<void> _onLoad(
    AppointmentsLoadRequested event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(const AppointmentsLoading());
    try {
      final list = await _list(status: event.status);
      emit(AppointmentsLoaded(list));
    } catch (e) {
      emit(AppointmentsFailure(_message(e)));
    }
  }

  Future<void> _onBook(
    AppointmentBookRequested event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(const AppointmentsLoading());
    try {
      final appointment = await _book(
        garageId: event.garageId,
        vehicleId: event.vehicleId,
        scheduledAt: event.scheduledAt,
        serviceDescription: event.serviceDescription,
        garageServiceIds: event.garageServiceIds,
        isOnsite: event.isOnsite,
        serviceLatitude: event.serviceLatitude,
        serviceLongitude: event.serviceLongitude,
      );
      emit(AppointmentActionSuccess(appointment));
    } catch (e) {
      emit(AppointmentsFailure(_message(e)));
    }
  }

  Future<void> _onReschedule(
    AppointmentRescheduleRequested event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(const AppointmentsLoading());
    try {
      final appointment = await _reschedule(
        id: event.id,
        scheduledAt: event.scheduledAt,
      );
      emit(AppointmentActionSuccess(appointment));
    } catch (e) {
      emit(AppointmentsFailure(_message(e)));
    }
  }

  Future<void> _onCancel(
    AppointmentCancelRequested event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(const AppointmentsLoading());
    try {
      final appointment = await _cancel(event.id);
      emit(AppointmentActionSuccess(appointment));
    } catch (e) {
      emit(AppointmentsFailure(_message(e)));
    }
  }

  String _message(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['error'] != null) return data['error'].toString();
    }
    return e.toString().contains('SocketException') || e.toString().contains('Connection')
        ? 'Network error.'
        : 'Something went wrong.';
  }
}
