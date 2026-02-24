library;

import 'package:equatable/equatable.dart';

import '../../domain/entities/appointment.dart';

abstract class AppointmentsState extends Equatable {
  const AppointmentsState();
  @override
  List<Object?> get props => [];
}

class AppointmentsInitial extends AppointmentsState {
  const AppointmentsInitial();
}

class AppointmentsLoading extends AppointmentsState {
  const AppointmentsLoading();
}

class AppointmentsLoaded extends AppointmentsState {
  const AppointmentsLoaded(this.appointments);
  final List<Appointment> appointments;
  @override
  List<Object?> get props => [appointments];
}

class AppointmentsFailure extends AppointmentsState {
  const AppointmentsFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class AppointmentActionSuccess extends AppointmentsState {
  const AppointmentActionSuccess(this.appointment);
  final Appointment appointment;
  @override
  List<Object?> get props => [appointment];
}
