library;

import 'package:equatable/equatable.dart';

import '../../domain/entities/vehicle.dart';

abstract class VehiclesState extends Equatable {
  const VehiclesState();
  @override
  List<Object?> get props => [];
}

class VehiclesInitial extends VehiclesState {
  const VehiclesInitial();
}

class VehiclesLoading extends VehiclesState {
  const VehiclesLoading();
}

class VehiclesLoaded extends VehiclesState {
  const VehiclesLoaded(this.vehicles);
  final List<Vehicle> vehicles;
  @override
  List<Object?> get props => [vehicles];
}

class VehicleDetailLoaded extends VehiclesState {
  const VehicleDetailLoaded(this.vehicle);
  final Vehicle vehicle;
  @override
  List<Object?> get props => [vehicle];
}

class VehicleActionSuccess extends VehiclesState {
  const VehicleActionSuccess(this.vehicle);
  final Vehicle vehicle;
  @override
  List<Object?> get props => [vehicle];
}

class VehicleDeleted extends VehiclesState {
  const VehicleDeleted(this.vehicleId);
  final String vehicleId;
  @override
  List<Object?> get props => [vehicleId];
}

class VehiclesFailure extends VehiclesState {
  const VehiclesFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
